--------------------------------------------------------
--  DDL for Package Body BEN_CBR_QUALD_BNF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CBR_QUALD_BNF_API" as
/* $Header: becqbapi.pkb 115.5 2002/12/13 06:53:39 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CBR_QUALD_BNF_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CBR_QUALD_BNF >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CBR_QUALD_BNF
  (p_validate                       in  boolean   default false
  ,p_cbr_quald_bnf_id               out nocopy number
  ,p_quald_bnf_flag                 in  varchar2  default 'N'
  ,p_cbr_elig_perd_strt_dt          in  date      default null
  ,p_cbr_elig_perd_end_dt           in  date      default null
  ,p_quald_bnf_person_id            in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_cvrd_emp_person_id             in  number    default null
  ,p_cbr_inelg_rsn_cd               in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_cqb_attribute_category         in  varchar2  default null
  ,p_cqb_attribute1                 in  varchar2  default null
  ,p_cqb_attribute2                 in  varchar2  default null
  ,p_cqb_attribute3                 in  varchar2  default null
  ,p_cqb_attribute4                 in  varchar2  default null
  ,p_cqb_attribute5                 in  varchar2  default null
  ,p_cqb_attribute6                 in  varchar2  default null
  ,p_cqb_attribute7                 in  varchar2  default null
  ,p_cqb_attribute8                 in  varchar2  default null
  ,p_cqb_attribute9                 in  varchar2  default null
  ,p_cqb_attribute10                in  varchar2  default null
  ,p_cqb_attribute11                in  varchar2  default null
  ,p_cqb_attribute12                in  varchar2  default null
  ,p_cqb_attribute13                in  varchar2  default null
  ,p_cqb_attribute14                in  varchar2  default null
  ,p_cqb_attribute15                in  varchar2  default null
  ,p_cqb_attribute16                in  varchar2  default null
  ,p_cqb_attribute17                in  varchar2  default null
  ,p_cqb_attribute18                in  varchar2  default null
  ,p_cqb_attribute19                in  varchar2  default null
  ,p_cqb_attribute20                in  varchar2  default null
  ,p_cqb_attribute21                in  varchar2  default null
  ,p_cqb_attribute22                in  varchar2  default null
  ,p_cqb_attribute23                in  varchar2  default null
  ,p_cqb_attribute24                in  varchar2  default null
  ,p_cqb_attribute25                in  varchar2  default null
  ,p_cqb_attribute26                in  varchar2  default null
  ,p_cqb_attribute27                in  varchar2  default null
  ,p_cqb_attribute28                in  varchar2  default null
  ,p_cqb_attribute29                in  varchar2  default null
  ,p_cqb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cbr_quald_bnf_id ben_cbr_quald_bnf.cbr_quald_bnf_id%TYPE;
  l_proc varchar2(72) := g_package||'create_CBR_QUALD_BNF';
  l_object_version_number ben_cbr_quald_bnf.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_CBR_QUALD_BNF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk1.create_CBR_QUALD_BNF_b
      (
       p_quald_bnf_flag                 =>  p_quald_bnf_flag
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_quald_bnf_person_id            =>  p_quald_bnf_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_cvrd_emp_person_id             =>  p_cvrd_emp_person_id
      ,p_cbr_inelg_rsn_cd               =>  p_cbr_inelg_rsn_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cqb_attribute_category         =>  p_cqb_attribute_category
      ,p_cqb_attribute1                 =>  p_cqb_attribute1
      ,p_cqb_attribute2                 =>  p_cqb_attribute2
      ,p_cqb_attribute3                 =>  p_cqb_attribute3
      ,p_cqb_attribute4                 =>  p_cqb_attribute4
      ,p_cqb_attribute5                 =>  p_cqb_attribute5
      ,p_cqb_attribute6                 =>  p_cqb_attribute6
      ,p_cqb_attribute7                 =>  p_cqb_attribute7
      ,p_cqb_attribute8                 =>  p_cqb_attribute8
      ,p_cqb_attribute9                 =>  p_cqb_attribute9
      ,p_cqb_attribute10                =>  p_cqb_attribute10
      ,p_cqb_attribute11                =>  p_cqb_attribute11
      ,p_cqb_attribute12                =>  p_cqb_attribute12
      ,p_cqb_attribute13                =>  p_cqb_attribute13
      ,p_cqb_attribute14                =>  p_cqb_attribute14
      ,p_cqb_attribute15                =>  p_cqb_attribute15
      ,p_cqb_attribute16                =>  p_cqb_attribute16
      ,p_cqb_attribute17                =>  p_cqb_attribute17
      ,p_cqb_attribute18                =>  p_cqb_attribute18
      ,p_cqb_attribute19                =>  p_cqb_attribute19
      ,p_cqb_attribute20                =>  p_cqb_attribute20
      ,p_cqb_attribute21                =>  p_cqb_attribute21
      ,p_cqb_attribute22                =>  p_cqb_attribute22
      ,p_cqb_attribute23                =>  p_cqb_attribute23
      ,p_cqb_attribute24                =>  p_cqb_attribute24
      ,p_cqb_attribute25                =>  p_cqb_attribute25
      ,p_cqb_attribute26                =>  p_cqb_attribute26
      ,p_cqb_attribute27                =>  p_cqb_attribute27
      ,p_cqb_attribute28                =>  p_cqb_attribute28
      ,p_cqb_attribute29                =>  p_cqb_attribute29
      ,p_cqb_attribute30                =>  p_cqb_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CBR_QUALD_BNF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CBR_QUALD_BNF
    --
  end;
  --
  ben_cqb_ins.ins
    (
     p_cbr_quald_bnf_id              => l_cbr_quald_bnf_id
    ,p_quald_bnf_flag                => p_quald_bnf_flag
    ,p_cbr_elig_perd_strt_dt         => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt          => p_cbr_elig_perd_end_dt
    ,p_quald_bnf_person_id           => p_quald_bnf_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_cvrd_emp_person_id            => p_cvrd_emp_person_id
    ,p_cbr_inelg_rsn_cd              => p_cbr_inelg_rsn_cd
    ,p_business_group_id             => p_business_group_id
    ,p_cqb_attribute_category        => p_cqb_attribute_category
    ,p_cqb_attribute1                => p_cqb_attribute1
    ,p_cqb_attribute2                => p_cqb_attribute2
    ,p_cqb_attribute3                => p_cqb_attribute3
    ,p_cqb_attribute4                => p_cqb_attribute4
    ,p_cqb_attribute5                => p_cqb_attribute5
    ,p_cqb_attribute6                => p_cqb_attribute6
    ,p_cqb_attribute7                => p_cqb_attribute7
    ,p_cqb_attribute8                => p_cqb_attribute8
    ,p_cqb_attribute9                => p_cqb_attribute9
    ,p_cqb_attribute10               => p_cqb_attribute10
    ,p_cqb_attribute11               => p_cqb_attribute11
    ,p_cqb_attribute12               => p_cqb_attribute12
    ,p_cqb_attribute13               => p_cqb_attribute13
    ,p_cqb_attribute14               => p_cqb_attribute14
    ,p_cqb_attribute15               => p_cqb_attribute15
    ,p_cqb_attribute16               => p_cqb_attribute16
    ,p_cqb_attribute17               => p_cqb_attribute17
    ,p_cqb_attribute18               => p_cqb_attribute18
    ,p_cqb_attribute19               => p_cqb_attribute19
    ,p_cqb_attribute20               => p_cqb_attribute20
    ,p_cqb_attribute21               => p_cqb_attribute21
    ,p_cqb_attribute22               => p_cqb_attribute22
    ,p_cqb_attribute23               => p_cqb_attribute23
    ,p_cqb_attribute24               => p_cqb_attribute24
    ,p_cqb_attribute25               => p_cqb_attribute25
    ,p_cqb_attribute26               => p_cqb_attribute26
    ,p_cqb_attribute27               => p_cqb_attribute27
    ,p_cqb_attribute28               => p_cqb_attribute28
    ,p_cqb_attribute29               => p_cqb_attribute29
    ,p_cqb_attribute30               => p_cqb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk1.create_CBR_QUALD_BNF_a
      (
       p_cbr_quald_bnf_id               =>  l_cbr_quald_bnf_id
      ,p_quald_bnf_flag                 =>  p_quald_bnf_flag
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_quald_bnf_person_id            =>  p_quald_bnf_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_cvrd_emp_person_id             =>  p_cvrd_emp_person_id
      ,p_cbr_inelg_rsn_cd               =>  p_cbr_inelg_rsn_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cqb_attribute_category         =>  p_cqb_attribute_category
      ,p_cqb_attribute1                 =>  p_cqb_attribute1
      ,p_cqb_attribute2                 =>  p_cqb_attribute2
      ,p_cqb_attribute3                 =>  p_cqb_attribute3
      ,p_cqb_attribute4                 =>  p_cqb_attribute4
      ,p_cqb_attribute5                 =>  p_cqb_attribute5
      ,p_cqb_attribute6                 =>  p_cqb_attribute6
      ,p_cqb_attribute7                 =>  p_cqb_attribute7
      ,p_cqb_attribute8                 =>  p_cqb_attribute8
      ,p_cqb_attribute9                 =>  p_cqb_attribute9
      ,p_cqb_attribute10                =>  p_cqb_attribute10
      ,p_cqb_attribute11                =>  p_cqb_attribute11
      ,p_cqb_attribute12                =>  p_cqb_attribute12
      ,p_cqb_attribute13                =>  p_cqb_attribute13
      ,p_cqb_attribute14                =>  p_cqb_attribute14
      ,p_cqb_attribute15                =>  p_cqb_attribute15
      ,p_cqb_attribute16                =>  p_cqb_attribute16
      ,p_cqb_attribute17                =>  p_cqb_attribute17
      ,p_cqb_attribute18                =>  p_cqb_attribute18
      ,p_cqb_attribute19                =>  p_cqb_attribute19
      ,p_cqb_attribute20                =>  p_cqb_attribute20
      ,p_cqb_attribute21                =>  p_cqb_attribute21
      ,p_cqb_attribute22                =>  p_cqb_attribute22
      ,p_cqb_attribute23                =>  p_cqb_attribute23
      ,p_cqb_attribute24                =>  p_cqb_attribute24
      ,p_cqb_attribute25                =>  p_cqb_attribute25
      ,p_cqb_attribute26                =>  p_cqb_attribute26
      ,p_cqb_attribute27                =>  p_cqb_attribute27
      ,p_cqb_attribute28                =>  p_cqb_attribute28
      ,p_cqb_attribute29                =>  p_cqb_attribute29
      ,p_cqb_attribute30                =>  p_cqb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CBR_QUALD_BNF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CBR_QUALD_BNF
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
  p_cbr_quald_bnf_id := l_cbr_quald_bnf_id;
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
    ROLLBACK TO create_CBR_QUALD_BNF;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cbr_quald_bnf_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CBR_QUALD_BNF;
    raise;
    --
end create_CBR_QUALD_BNF;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CBR_QUALD_BNF >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CBR_QUALD_BNF
  (p_validate                       in  boolean   default false
  ,p_cbr_quald_bnf_id               in  number
  ,p_quald_bnf_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_cbr_elig_perd_strt_dt          in  date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt           in  date      default hr_api.g_date
  ,p_quald_bnf_person_id            in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_cvrd_emp_person_id             in  number    default hr_api.g_number
  ,p_cbr_inelg_rsn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cqb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cqb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CBR_QUALD_BNF';
  l_object_version_number ben_cbr_quald_bnf.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_CBR_QUALD_BNF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk2.update_CBR_QUALD_BNF_b
      (
       p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_quald_bnf_flag                 =>  p_quald_bnf_flag
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_quald_bnf_person_id            =>  p_quald_bnf_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_cvrd_emp_person_id             =>  p_cvrd_emp_person_id
      ,p_cbr_inelg_rsn_cd               =>  p_cbr_inelg_rsn_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cqb_attribute_category         =>  p_cqb_attribute_category
      ,p_cqb_attribute1                 =>  p_cqb_attribute1
      ,p_cqb_attribute2                 =>  p_cqb_attribute2
      ,p_cqb_attribute3                 =>  p_cqb_attribute3
      ,p_cqb_attribute4                 =>  p_cqb_attribute4
      ,p_cqb_attribute5                 =>  p_cqb_attribute5
      ,p_cqb_attribute6                 =>  p_cqb_attribute6
      ,p_cqb_attribute7                 =>  p_cqb_attribute7
      ,p_cqb_attribute8                 =>  p_cqb_attribute8
      ,p_cqb_attribute9                 =>  p_cqb_attribute9
      ,p_cqb_attribute10                =>  p_cqb_attribute10
      ,p_cqb_attribute11                =>  p_cqb_attribute11
      ,p_cqb_attribute12                =>  p_cqb_attribute12
      ,p_cqb_attribute13                =>  p_cqb_attribute13
      ,p_cqb_attribute14                =>  p_cqb_attribute14
      ,p_cqb_attribute15                =>  p_cqb_attribute15
      ,p_cqb_attribute16                =>  p_cqb_attribute16
      ,p_cqb_attribute17                =>  p_cqb_attribute17
      ,p_cqb_attribute18                =>  p_cqb_attribute18
      ,p_cqb_attribute19                =>  p_cqb_attribute19
      ,p_cqb_attribute20                =>  p_cqb_attribute20
      ,p_cqb_attribute21                =>  p_cqb_attribute21
      ,p_cqb_attribute22                =>  p_cqb_attribute22
      ,p_cqb_attribute23                =>  p_cqb_attribute23
      ,p_cqb_attribute24                =>  p_cqb_attribute24
      ,p_cqb_attribute25                =>  p_cqb_attribute25
      ,p_cqb_attribute26                =>  p_cqb_attribute26
      ,p_cqb_attribute27                =>  p_cqb_attribute27
      ,p_cqb_attribute28                =>  p_cqb_attribute28
      ,p_cqb_attribute29                =>  p_cqb_attribute29
      ,p_cqb_attribute30                =>  p_cqb_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CBR_QUALD_BNF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CBR_QUALD_BNF
    --
  end;
  --
  ben_cqb_upd.upd
    (
     p_cbr_quald_bnf_id              => p_cbr_quald_bnf_id
    ,p_quald_bnf_flag                => p_quald_bnf_flag
    ,p_cbr_elig_perd_strt_dt         => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt          => p_cbr_elig_perd_end_dt
    ,p_quald_bnf_person_id           => p_quald_bnf_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_cvrd_emp_person_id            => p_cvrd_emp_person_id
    ,p_cbr_inelg_rsn_cd              => p_cbr_inelg_rsn_cd
    ,p_business_group_id             => p_business_group_id
    ,p_cqb_attribute_category        => p_cqb_attribute_category
    ,p_cqb_attribute1                => p_cqb_attribute1
    ,p_cqb_attribute2                => p_cqb_attribute2
    ,p_cqb_attribute3                => p_cqb_attribute3
    ,p_cqb_attribute4                => p_cqb_attribute4
    ,p_cqb_attribute5                => p_cqb_attribute5
    ,p_cqb_attribute6                => p_cqb_attribute6
    ,p_cqb_attribute7                => p_cqb_attribute7
    ,p_cqb_attribute8                => p_cqb_attribute8
    ,p_cqb_attribute9                => p_cqb_attribute9
    ,p_cqb_attribute10               => p_cqb_attribute10
    ,p_cqb_attribute11               => p_cqb_attribute11
    ,p_cqb_attribute12               => p_cqb_attribute12
    ,p_cqb_attribute13               => p_cqb_attribute13
    ,p_cqb_attribute14               => p_cqb_attribute14
    ,p_cqb_attribute15               => p_cqb_attribute15
    ,p_cqb_attribute16               => p_cqb_attribute16
    ,p_cqb_attribute17               => p_cqb_attribute17
    ,p_cqb_attribute18               => p_cqb_attribute18
    ,p_cqb_attribute19               => p_cqb_attribute19
    ,p_cqb_attribute20               => p_cqb_attribute20
    ,p_cqb_attribute21               => p_cqb_attribute21
    ,p_cqb_attribute22               => p_cqb_attribute22
    ,p_cqb_attribute23               => p_cqb_attribute23
    ,p_cqb_attribute24               => p_cqb_attribute24
    ,p_cqb_attribute25               => p_cqb_attribute25
    ,p_cqb_attribute26               => p_cqb_attribute26
    ,p_cqb_attribute27               => p_cqb_attribute27
    ,p_cqb_attribute28               => p_cqb_attribute28
    ,p_cqb_attribute29               => p_cqb_attribute29
    ,p_cqb_attribute30               => p_cqb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk2.update_CBR_QUALD_BNF_a
      (
       p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_quald_bnf_flag                 =>  p_quald_bnf_flag
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_quald_bnf_person_id            =>  p_quald_bnf_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_cvrd_emp_person_id             =>  p_cvrd_emp_person_id
      ,p_cbr_inelg_rsn_cd               =>  p_cbr_inelg_rsn_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cqb_attribute_category         =>  p_cqb_attribute_category
      ,p_cqb_attribute1                 =>  p_cqb_attribute1
      ,p_cqb_attribute2                 =>  p_cqb_attribute2
      ,p_cqb_attribute3                 =>  p_cqb_attribute3
      ,p_cqb_attribute4                 =>  p_cqb_attribute4
      ,p_cqb_attribute5                 =>  p_cqb_attribute5
      ,p_cqb_attribute6                 =>  p_cqb_attribute6
      ,p_cqb_attribute7                 =>  p_cqb_attribute7
      ,p_cqb_attribute8                 =>  p_cqb_attribute8
      ,p_cqb_attribute9                 =>  p_cqb_attribute9
      ,p_cqb_attribute10                =>  p_cqb_attribute10
      ,p_cqb_attribute11                =>  p_cqb_attribute11
      ,p_cqb_attribute12                =>  p_cqb_attribute12
      ,p_cqb_attribute13                =>  p_cqb_attribute13
      ,p_cqb_attribute14                =>  p_cqb_attribute14
      ,p_cqb_attribute15                =>  p_cqb_attribute15
      ,p_cqb_attribute16                =>  p_cqb_attribute16
      ,p_cqb_attribute17                =>  p_cqb_attribute17
      ,p_cqb_attribute18                =>  p_cqb_attribute18
      ,p_cqb_attribute19                =>  p_cqb_attribute19
      ,p_cqb_attribute20                =>  p_cqb_attribute20
      ,p_cqb_attribute21                =>  p_cqb_attribute21
      ,p_cqb_attribute22                =>  p_cqb_attribute22
      ,p_cqb_attribute23                =>  p_cqb_attribute23
      ,p_cqb_attribute24                =>  p_cqb_attribute24
      ,p_cqb_attribute25                =>  p_cqb_attribute25
      ,p_cqb_attribute26                =>  p_cqb_attribute26
      ,p_cqb_attribute27                =>  p_cqb_attribute27
      ,p_cqb_attribute28                =>  p_cqb_attribute28
      ,p_cqb_attribute29                =>  p_cqb_attribute29
      ,p_cqb_attribute30                =>  p_cqb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CBR_QUALD_BNF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CBR_QUALD_BNF
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
    ROLLBACK TO update_CBR_QUALD_BNF;
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
    ROLLBACK TO update_CBR_QUALD_BNF;
    raise;
    --
end update_CBR_QUALD_BNF;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CBR_QUALD_BNF >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_QUALD_BNF
  (p_validate                       in  boolean  default false
  ,p_cbr_quald_bnf_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CBR_QUALD_BNF';
  l_object_version_number ben_cbr_quald_bnf.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_CBR_QUALD_BNF;
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
    -- Start of API User Hook for the before hook of delete_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk3.delete_CBR_QUALD_BNF_b
      (
       p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CBR_QUALD_BNF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CBR_QUALD_BNF
    --
  end;
  --
  ben_cqb_del.del
    (
     p_cbr_quald_bnf_id              => p_cbr_quald_bnf_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CBR_QUALD_BNF
    --
    ben_CBR_QUALD_BNF_bk3.delete_CBR_QUALD_BNF_a
      (
       p_cbr_quald_bnf_id               =>  p_cbr_quald_bnf_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CBR_QUALD_BNF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CBR_QUALD_BNF
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
    ROLLBACK TO delete_CBR_QUALD_BNF;
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
    ROLLBACK TO delete_CBR_QUALD_BNF;
    raise;
    --
end delete_CBR_QUALD_BNF;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cbr_quald_bnf_id                   in     number
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
  ben_cqb_shd.lck
    (
      p_cbr_quald_bnf_id                 => p_cbr_quald_bnf_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_CBR_QUALD_BNF_api;

/
