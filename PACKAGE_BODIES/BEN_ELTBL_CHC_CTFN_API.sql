--------------------------------------------------------
--  DDL for Package Body BEN_ELTBL_CHC_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELTBL_CHC_CTFN_API" as
/* $Header: beeccapi.pkb 120.0 2005/05/28 01:48:42 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELTBL_CHC_CTFN_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELTBL_CHC_CTFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELTBL_CHC_CTFN
  (p_validate                       in  boolean   default false
  ,p_elctbl_chc_ctfn_id             out nocopy number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_enrt_bnft_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ecc_attribute_category         in  varchar2  default null
  ,p_ecc_attribute1                 in  varchar2  default null
  ,p_ecc_attribute2                 in  varchar2  default null
  ,p_ecc_attribute3                 in  varchar2  default null
  ,p_ecc_attribute4                 in  varchar2  default null
  ,p_ecc_attribute5                 in  varchar2  default null
  ,p_ecc_attribute6                 in  varchar2  default null
  ,p_ecc_attribute7                 in  varchar2  default null
  ,p_ecc_attribute8                 in  varchar2  default null
  ,p_ecc_attribute9                 in  varchar2  default null
  ,p_ecc_attribute10                in  varchar2  default null
  ,p_ecc_attribute11                in  varchar2  default null
  ,p_ecc_attribute12                in  varchar2  default null
  ,p_ecc_attribute13                in  varchar2  default null
  ,p_ecc_attribute14                in  varchar2  default null
  ,p_ecc_attribute15                in  varchar2  default null
  ,p_ecc_attribute16                in  varchar2  default null
  ,p_ecc_attribute17                in  varchar2  default null
  ,p_ecc_attribute18                in  varchar2  default null
  ,p_ecc_attribute19                in  varchar2  default null
  ,p_ecc_attribute20                in  varchar2  default null
  ,p_ecc_attribute21                in  varchar2  default null
  ,p_ecc_attribute22                in  varchar2  default null
  ,p_ecc_attribute23                in  varchar2  default null
  ,p_ecc_attribute24                in  varchar2  default null
  ,p_ecc_attribute25                in  varchar2  default null
  ,p_ecc_attribute26                in  varchar2  default null
  ,p_ecc_attribute27                in  varchar2  default null
  ,p_ecc_attribute28                in  varchar2  default null
  ,p_ecc_attribute29                in  varchar2  default null
  ,p_ecc_attribute30                in  varchar2  default null
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elctbl_chc_ctfn_id ben_elctbl_chc_ctfn.elctbl_chc_ctfn_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ELTBL_CHC_CTFN';
  l_object_version_number ben_elctbl_chc_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELTBL_CHC_CTFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk1.create_ELTBL_CHC_CTFN_b
      (
       p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecc_attribute_category         =>  p_ecc_attribute_category
      ,p_ecc_attribute1                 =>  p_ecc_attribute1
      ,p_ecc_attribute2                 =>  p_ecc_attribute2
      ,p_ecc_attribute3                 =>  p_ecc_attribute3
      ,p_ecc_attribute4                 =>  p_ecc_attribute4
      ,p_ecc_attribute5                 =>  p_ecc_attribute5
      ,p_ecc_attribute6                 =>  p_ecc_attribute6
      ,p_ecc_attribute7                 =>  p_ecc_attribute7
      ,p_ecc_attribute8                 =>  p_ecc_attribute8
      ,p_ecc_attribute9                 =>  p_ecc_attribute9
      ,p_ecc_attribute10                =>  p_ecc_attribute10
      ,p_ecc_attribute11                =>  p_ecc_attribute11
      ,p_ecc_attribute12                =>  p_ecc_attribute12
      ,p_ecc_attribute13                =>  p_ecc_attribute13
      ,p_ecc_attribute14                =>  p_ecc_attribute14
      ,p_ecc_attribute15                =>  p_ecc_attribute15
      ,p_ecc_attribute16                =>  p_ecc_attribute16
      ,p_ecc_attribute17                =>  p_ecc_attribute17
      ,p_ecc_attribute18                =>  p_ecc_attribute18
      ,p_ecc_attribute19                =>  p_ecc_attribute19
      ,p_ecc_attribute20                =>  p_ecc_attribute20
      ,p_ecc_attribute21                =>  p_ecc_attribute21
      ,p_ecc_attribute22                =>  p_ecc_attribute22
      ,p_ecc_attribute23                =>  p_ecc_attribute23
      ,p_ecc_attribute24                =>  p_ecc_attribute24
      ,p_ecc_attribute25                =>  p_ecc_attribute25
      ,p_ecc_attribute26                =>  p_ecc_attribute26
      ,p_ecc_attribute27                =>  p_ecc_attribute27
      ,p_ecc_attribute28                =>  p_ecc_attribute28
      ,p_ecc_attribute29                =>  p_ecc_attribute29
      ,p_ecc_attribute30                =>  p_ecc_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELTBL_CHC_CTFN
    --
  end;
  --
  ben_ecc_ins.ins
    (
     p_elctbl_chc_ctfn_id            => l_elctbl_chc_ctfn_id
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_business_group_id             => p_business_group_id
    ,p_ecc_attribute_category        => p_ecc_attribute_category
    ,p_ecc_attribute1                => p_ecc_attribute1
    ,p_ecc_attribute2                => p_ecc_attribute2
    ,p_ecc_attribute3                => p_ecc_attribute3
    ,p_ecc_attribute4                => p_ecc_attribute4
    ,p_ecc_attribute5                => p_ecc_attribute5
    ,p_ecc_attribute6                => p_ecc_attribute6
    ,p_ecc_attribute7                => p_ecc_attribute7
    ,p_ecc_attribute8                => p_ecc_attribute8
    ,p_ecc_attribute9                => p_ecc_attribute9
    ,p_ecc_attribute10               => p_ecc_attribute10
    ,p_ecc_attribute11               => p_ecc_attribute11
    ,p_ecc_attribute12               => p_ecc_attribute12
    ,p_ecc_attribute13               => p_ecc_attribute13
    ,p_ecc_attribute14               => p_ecc_attribute14
    ,p_ecc_attribute15               => p_ecc_attribute15
    ,p_ecc_attribute16               => p_ecc_attribute16
    ,p_ecc_attribute17               => p_ecc_attribute17
    ,p_ecc_attribute18               => p_ecc_attribute18
    ,p_ecc_attribute19               => p_ecc_attribute19
    ,p_ecc_attribute20               => p_ecc_attribute20
    ,p_ecc_attribute21               => p_ecc_attribute21
    ,p_ecc_attribute22               => p_ecc_attribute22
    ,p_ecc_attribute23               => p_ecc_attribute23
    ,p_ecc_attribute24               => p_ecc_attribute24
    ,p_ecc_attribute25               => p_ecc_attribute25
    ,p_ecc_attribute26               => p_ecc_attribute26
    ,p_ecc_attribute27               => p_ecc_attribute27
    ,p_ecc_attribute28               => p_ecc_attribute28
    ,p_ecc_attribute29               => p_ecc_attribute29
    ,p_ecc_attribute30               => p_ecc_attribute30
    ,p_susp_if_ctfn_not_prvd_flag    => p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             => p_ctfn_determine_cd
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk1.create_ELTBL_CHC_CTFN_a
      (
       p_elctbl_chc_ctfn_id             =>  l_elctbl_chc_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecc_attribute_category         =>  p_ecc_attribute_category
      ,p_ecc_attribute1                 =>  p_ecc_attribute1
      ,p_ecc_attribute2                 =>  p_ecc_attribute2
      ,p_ecc_attribute3                 =>  p_ecc_attribute3
      ,p_ecc_attribute4                 =>  p_ecc_attribute4
      ,p_ecc_attribute5                 =>  p_ecc_attribute5
      ,p_ecc_attribute6                 =>  p_ecc_attribute6
      ,p_ecc_attribute7                 =>  p_ecc_attribute7
      ,p_ecc_attribute8                 =>  p_ecc_attribute8
      ,p_ecc_attribute9                 =>  p_ecc_attribute9
      ,p_ecc_attribute10                =>  p_ecc_attribute10
      ,p_ecc_attribute11                =>  p_ecc_attribute11
      ,p_ecc_attribute12                =>  p_ecc_attribute12
      ,p_ecc_attribute13                =>  p_ecc_attribute13
      ,p_ecc_attribute14                =>  p_ecc_attribute14
      ,p_ecc_attribute15                =>  p_ecc_attribute15
      ,p_ecc_attribute16                =>  p_ecc_attribute16
      ,p_ecc_attribute17                =>  p_ecc_attribute17
      ,p_ecc_attribute18                =>  p_ecc_attribute18
      ,p_ecc_attribute19                =>  p_ecc_attribute19
      ,p_ecc_attribute20                =>  p_ecc_attribute20
      ,p_ecc_attribute21                =>  p_ecc_attribute21
      ,p_ecc_attribute22                =>  p_ecc_attribute22
      ,p_ecc_attribute23                =>  p_ecc_attribute23
      ,p_ecc_attribute24                =>  p_ecc_attribute24
      ,p_ecc_attribute25                =>  p_ecc_attribute25
      ,p_ecc_attribute26                =>  p_ecc_attribute26
      ,p_ecc_attribute27                =>  p_ecc_attribute27
      ,p_ecc_attribute28                =>  p_ecc_attribute28
      ,p_ecc_attribute29                =>  p_ecc_attribute29
      ,p_ecc_attribute30                =>  p_ecc_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELTBL_CHC_CTFN
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
  p_elctbl_chc_ctfn_id := l_elctbl_chc_ctfn_id;
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
    ROLLBACK TO create_ELTBL_CHC_CTFN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elctbl_chc_ctfn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELTBL_CHC_CTFN;
    p_elctbl_chc_ctfn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_ELTBL_CHC_CTFN;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELTBL_CHC_CTFN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELTBL_CHC_CTFN
  (p_validate                       in  boolean   default false
  ,p_elctbl_chc_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_enrt_bnft_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ecc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELTBL_CHC_CTFN';
  l_object_version_number ben_elctbl_chc_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELTBL_CHC_CTFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk2.update_ELTBL_CHC_CTFN_b
      (
       p_elctbl_chc_ctfn_id             =>  p_elctbl_chc_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecc_attribute_category         =>  p_ecc_attribute_category
      ,p_ecc_attribute1                 =>  p_ecc_attribute1
      ,p_ecc_attribute2                 =>  p_ecc_attribute2
      ,p_ecc_attribute3                 =>  p_ecc_attribute3
      ,p_ecc_attribute4                 =>  p_ecc_attribute4
      ,p_ecc_attribute5                 =>  p_ecc_attribute5
      ,p_ecc_attribute6                 =>  p_ecc_attribute6
      ,p_ecc_attribute7                 =>  p_ecc_attribute7
      ,p_ecc_attribute8                 =>  p_ecc_attribute8
      ,p_ecc_attribute9                 =>  p_ecc_attribute9
      ,p_ecc_attribute10                =>  p_ecc_attribute10
      ,p_ecc_attribute11                =>  p_ecc_attribute11
      ,p_ecc_attribute12                =>  p_ecc_attribute12
      ,p_ecc_attribute13                =>  p_ecc_attribute13
      ,p_ecc_attribute14                =>  p_ecc_attribute14
      ,p_ecc_attribute15                =>  p_ecc_attribute15
      ,p_ecc_attribute16                =>  p_ecc_attribute16
      ,p_ecc_attribute17                =>  p_ecc_attribute17
      ,p_ecc_attribute18                =>  p_ecc_attribute18
      ,p_ecc_attribute19                =>  p_ecc_attribute19
      ,p_ecc_attribute20                =>  p_ecc_attribute20
      ,p_ecc_attribute21                =>  p_ecc_attribute21
      ,p_ecc_attribute22                =>  p_ecc_attribute22
      ,p_ecc_attribute23                =>  p_ecc_attribute23
      ,p_ecc_attribute24                =>  p_ecc_attribute24
      ,p_ecc_attribute25                =>  p_ecc_attribute25
      ,p_ecc_attribute26                =>  p_ecc_attribute26
      ,p_ecc_attribute27                =>  p_ecc_attribute27
      ,p_ecc_attribute28                =>  p_ecc_attribute28
      ,p_ecc_attribute29                =>  p_ecc_attribute29
      ,p_ecc_attribute30                =>  p_ecc_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELTBL_CHC_CTFN
    --
  end;
  --
  ben_ecc_upd.upd
    (
     p_elctbl_chc_ctfn_id            => p_elctbl_chc_ctfn_id
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_business_group_id             => p_business_group_id
    ,p_ecc_attribute_category        => p_ecc_attribute_category
    ,p_ecc_attribute1                => p_ecc_attribute1
    ,p_ecc_attribute2                => p_ecc_attribute2
    ,p_ecc_attribute3                => p_ecc_attribute3
    ,p_ecc_attribute4                => p_ecc_attribute4
    ,p_ecc_attribute5                => p_ecc_attribute5
    ,p_ecc_attribute6                => p_ecc_attribute6
    ,p_ecc_attribute7                => p_ecc_attribute7
    ,p_ecc_attribute8                => p_ecc_attribute8
    ,p_ecc_attribute9                => p_ecc_attribute9
    ,p_ecc_attribute10               => p_ecc_attribute10
    ,p_ecc_attribute11               => p_ecc_attribute11
    ,p_ecc_attribute12               => p_ecc_attribute12
    ,p_ecc_attribute13               => p_ecc_attribute13
    ,p_ecc_attribute14               => p_ecc_attribute14
    ,p_ecc_attribute15               => p_ecc_attribute15
    ,p_ecc_attribute16               => p_ecc_attribute16
    ,p_ecc_attribute17               => p_ecc_attribute17
    ,p_ecc_attribute18               => p_ecc_attribute18
    ,p_ecc_attribute19               => p_ecc_attribute19
    ,p_ecc_attribute20               => p_ecc_attribute20
    ,p_ecc_attribute21               => p_ecc_attribute21
    ,p_ecc_attribute22               => p_ecc_attribute22
    ,p_ecc_attribute23               => p_ecc_attribute23
    ,p_ecc_attribute24               => p_ecc_attribute24
    ,p_ecc_attribute25               => p_ecc_attribute25
    ,p_ecc_attribute26               => p_ecc_attribute26
    ,p_ecc_attribute27               => p_ecc_attribute27
    ,p_ecc_attribute28               => p_ecc_attribute28
    ,p_ecc_attribute29               => p_ecc_attribute29
    ,p_ecc_attribute30               => p_ecc_attribute30
    ,p_susp_if_ctfn_not_prvd_flag    => p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             => p_ctfn_determine_cd
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk2.update_ELTBL_CHC_CTFN_a
      (
       p_elctbl_chc_ctfn_id             =>  p_elctbl_chc_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ecc_attribute_category         =>  p_ecc_attribute_category
      ,p_ecc_attribute1                 =>  p_ecc_attribute1
      ,p_ecc_attribute2                 =>  p_ecc_attribute2
      ,p_ecc_attribute3                 =>  p_ecc_attribute3
      ,p_ecc_attribute4                 =>  p_ecc_attribute4
      ,p_ecc_attribute5                 =>  p_ecc_attribute5
      ,p_ecc_attribute6                 =>  p_ecc_attribute6
      ,p_ecc_attribute7                 =>  p_ecc_attribute7
      ,p_ecc_attribute8                 =>  p_ecc_attribute8
      ,p_ecc_attribute9                 =>  p_ecc_attribute9
      ,p_ecc_attribute10                =>  p_ecc_attribute10
      ,p_ecc_attribute11                =>  p_ecc_attribute11
      ,p_ecc_attribute12                =>  p_ecc_attribute12
      ,p_ecc_attribute13                =>  p_ecc_attribute13
      ,p_ecc_attribute14                =>  p_ecc_attribute14
      ,p_ecc_attribute15                =>  p_ecc_attribute15
      ,p_ecc_attribute16                =>  p_ecc_attribute16
      ,p_ecc_attribute17                =>  p_ecc_attribute17
      ,p_ecc_attribute18                =>  p_ecc_attribute18
      ,p_ecc_attribute19                =>  p_ecc_attribute19
      ,p_ecc_attribute20                =>  p_ecc_attribute20
      ,p_ecc_attribute21                =>  p_ecc_attribute21
      ,p_ecc_attribute22                =>  p_ecc_attribute22
      ,p_ecc_attribute23                =>  p_ecc_attribute23
      ,p_ecc_attribute24                =>  p_ecc_attribute24
      ,p_ecc_attribute25                =>  p_ecc_attribute25
      ,p_ecc_attribute26                =>  p_ecc_attribute26
      ,p_ecc_attribute27                =>  p_ecc_attribute27
      ,p_ecc_attribute28                =>  p_ecc_attribute28
      ,p_ecc_attribute29                =>  p_ecc_attribute29
      ,p_ecc_attribute30                =>  p_ecc_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELTBL_CHC_CTFN
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
    ROLLBACK TO update_ELTBL_CHC_CTFN;
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
    ROLLBACK TO update_ELTBL_CHC_CTFN;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_ELTBL_CHC_CTFN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELTBL_CHC_CTFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELTBL_CHC_CTFN
  (p_validate                       in  boolean  default false
  ,p_elctbl_chc_ctfn_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELTBL_CHC_CTFN';
  l_object_version_number ben_elctbl_chc_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELTBL_CHC_CTFN;
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
    -- Start of API User Hook for the before hook of delete_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk3.delete_ELTBL_CHC_CTFN_b
      (
       p_elctbl_chc_ctfn_id             =>  p_elctbl_chc_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELTBL_CHC_CTFN
    --
  end;
  --
  ben_ecc_del.del
    (
     p_elctbl_chc_ctfn_id            => p_elctbl_chc_ctfn_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELTBL_CHC_CTFN
    --
    ben_ELTBL_CHC_CTFN_bk3.delete_ELTBL_CHC_CTFN_a
      (
       p_elctbl_chc_ctfn_id             =>  p_elctbl_chc_ctfn_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELTBL_CHC_CTFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELTBL_CHC_CTFN
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
    ROLLBACK TO delete_ELTBL_CHC_CTFN;
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
    ROLLBACK TO delete_ELTBL_CHC_CTFN;
    raise;
    --
end delete_ELTBL_CHC_CTFN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elctbl_chc_ctfn_id                   in     number
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
  ben_ecc_shd.lck
    (
      p_elctbl_chc_ctfn_id                 => p_elctbl_chc_ctfn_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_ELTBL_CHC_CTFN_api;

/
