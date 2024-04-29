--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_BENEFICIARY_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_BENEFICIARY_CTFN_API" as
/* $Header: bepcxapi.pkb 120.0 2005/05/28 10:20:40 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_Beneficiary_Ctfn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_Beneficiary_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_Beneficiary_Ctfn
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_ctfn_id                 out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_id                          in  number    default null
  ,p_bnf_ctfn_typ_cd                in  varchar2  default null
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2  default null
  ,p_pfd_flag                       in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default null
  ,p_ctfn_rqd_when_rl               in  number    default null
  ,p_bnf_typ_cd                     in  varchar2  default null
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_pcx_attribute_category         in  varchar2  default null
  ,p_pcx_attribute1                 in  varchar2  default null
  ,p_pcx_attribute2                 in  varchar2  default null
  ,p_pcx_attribute3                 in  varchar2  default null
  ,p_pcx_attribute4                 in  varchar2  default null
  ,p_pcx_attribute5                 in  varchar2  default null
  ,p_pcx_attribute6                 in  varchar2  default null
  ,p_pcx_attribute7                 in  varchar2  default null
  ,p_pcx_attribute8                 in  varchar2  default null
  ,p_pcx_attribute9                 in  varchar2  default null
  ,p_pcx_attribute10                in  varchar2  default null
  ,p_pcx_attribute11                in  varchar2  default null
  ,p_pcx_attribute12                in  varchar2  default null
  ,p_pcx_attribute13                in  varchar2  default null
  ,p_pcx_attribute14                in  varchar2  default null
  ,p_pcx_attribute15                in  varchar2  default null
  ,p_pcx_attribute16                in  varchar2  default null
  ,p_pcx_attribute17                in  varchar2  default null
  ,p_pcx_attribute18                in  varchar2  default null
  ,p_pcx_attribute19                in  varchar2  default null
  ,p_pcx_attribute20                in  varchar2  default null
  ,p_pcx_attribute21                in  varchar2  default null
  ,p_pcx_attribute22                in  varchar2  default null
  ,p_pcx_attribute23                in  varchar2  default null
  ,p_pcx_attribute24                in  varchar2  default null
  ,p_pcx_attribute25                in  varchar2  default null
  ,p_pcx_attribute26                in  varchar2  default null
  ,p_pcx_attribute27                in  varchar2  default null
  ,p_pcx_attribute28                in  varchar2  default null
  ,p_pcx_attribute29                in  varchar2  default null
  ,p_pcx_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_bnf_ctfn_id ben_pl_bnf_ctfn_f.pl_bnf_ctfn_id%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan_Beneficiary_Ctfn';
  l_object_version_number ben_pl_bnf_ctfn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Plan_Beneficiary_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk1.create_Plan_Beneficiary_Ctfn_b
      (
       p_pl_id                          =>  p_pl_id
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_bnf_typ_cd                     =>  p_bnf_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcx_attribute_category         =>  p_pcx_attribute_category
      ,p_pcx_attribute1                 =>  p_pcx_attribute1
      ,p_pcx_attribute2                 =>  p_pcx_attribute2
      ,p_pcx_attribute3                 =>  p_pcx_attribute3
      ,p_pcx_attribute4                 =>  p_pcx_attribute4
      ,p_pcx_attribute5                 =>  p_pcx_attribute5
      ,p_pcx_attribute6                 =>  p_pcx_attribute6
      ,p_pcx_attribute7                 =>  p_pcx_attribute7
      ,p_pcx_attribute8                 =>  p_pcx_attribute8
      ,p_pcx_attribute9                 =>  p_pcx_attribute9
      ,p_pcx_attribute10                =>  p_pcx_attribute10
      ,p_pcx_attribute11                =>  p_pcx_attribute11
      ,p_pcx_attribute12                =>  p_pcx_attribute12
      ,p_pcx_attribute13                =>  p_pcx_attribute13
      ,p_pcx_attribute14                =>  p_pcx_attribute14
      ,p_pcx_attribute15                =>  p_pcx_attribute15
      ,p_pcx_attribute16                =>  p_pcx_attribute16
      ,p_pcx_attribute17                =>  p_pcx_attribute17
      ,p_pcx_attribute18                =>  p_pcx_attribute18
      ,p_pcx_attribute19                =>  p_pcx_attribute19
      ,p_pcx_attribute20                =>  p_pcx_attribute20
      ,p_pcx_attribute21                =>  p_pcx_attribute21
      ,p_pcx_attribute22                =>  p_pcx_attribute22
      ,p_pcx_attribute23                =>  p_pcx_attribute23
      ,p_pcx_attribute24                =>  p_pcx_attribute24
      ,p_pcx_attribute25                =>  p_pcx_attribute25
      ,p_pcx_attribute26                =>  p_pcx_attribute26
      ,p_pcx_attribute27                =>  p_pcx_attribute27
      ,p_pcx_attribute28                =>  p_pcx_attribute28
      ,p_pcx_attribute29                =>  p_pcx_attribute29
      ,p_pcx_attribute30                =>  p_pcx_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan_Beneficiary_Ctfn
    --
  end;
  --
  ben_pcx_ins.ins
    (
     p_pl_bnf_ctfn_id                => l_pl_bnf_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_id                         => p_pl_id
    ,p_bnf_ctfn_typ_cd               => p_bnf_ctfn_typ_cd
    ,p_lack_ctfn_sspnd_enrt_flag     => p_lack_ctfn_sspnd_enrt_flag
    ,p_pfd_flag                      => p_pfd_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_bnf_typ_cd                    => p_bnf_typ_cd
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_pcx_attribute_category        => p_pcx_attribute_category
    ,p_pcx_attribute1                => p_pcx_attribute1
    ,p_pcx_attribute2                => p_pcx_attribute2
    ,p_pcx_attribute3                => p_pcx_attribute3
    ,p_pcx_attribute4                => p_pcx_attribute4
    ,p_pcx_attribute5                => p_pcx_attribute5
    ,p_pcx_attribute6                => p_pcx_attribute6
    ,p_pcx_attribute7                => p_pcx_attribute7
    ,p_pcx_attribute8                => p_pcx_attribute8
    ,p_pcx_attribute9                => p_pcx_attribute9
    ,p_pcx_attribute10               => p_pcx_attribute10
    ,p_pcx_attribute11               => p_pcx_attribute11
    ,p_pcx_attribute12               => p_pcx_attribute12
    ,p_pcx_attribute13               => p_pcx_attribute13
    ,p_pcx_attribute14               => p_pcx_attribute14
    ,p_pcx_attribute15               => p_pcx_attribute15
    ,p_pcx_attribute16               => p_pcx_attribute16
    ,p_pcx_attribute17               => p_pcx_attribute17
    ,p_pcx_attribute18               => p_pcx_attribute18
    ,p_pcx_attribute19               => p_pcx_attribute19
    ,p_pcx_attribute20               => p_pcx_attribute20
    ,p_pcx_attribute21               => p_pcx_attribute21
    ,p_pcx_attribute22               => p_pcx_attribute22
    ,p_pcx_attribute23               => p_pcx_attribute23
    ,p_pcx_attribute24               => p_pcx_attribute24
    ,p_pcx_attribute25               => p_pcx_attribute25
    ,p_pcx_attribute26               => p_pcx_attribute26
    ,p_pcx_attribute27               => p_pcx_attribute27
    ,p_pcx_attribute28               => p_pcx_attribute28
    ,p_pcx_attribute29               => p_pcx_attribute29
    ,p_pcx_attribute30               => p_pcx_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk1.create_Plan_Beneficiary_Ctfn_a
      (
       p_pl_bnf_ctfn_id                 =>  l_pl_bnf_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_id                          =>  p_pl_id
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_bnf_typ_cd                     =>  p_bnf_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcx_attribute_category         =>  p_pcx_attribute_category
      ,p_pcx_attribute1                 =>  p_pcx_attribute1
      ,p_pcx_attribute2                 =>  p_pcx_attribute2
      ,p_pcx_attribute3                 =>  p_pcx_attribute3
      ,p_pcx_attribute4                 =>  p_pcx_attribute4
      ,p_pcx_attribute5                 =>  p_pcx_attribute5
      ,p_pcx_attribute6                 =>  p_pcx_attribute6
      ,p_pcx_attribute7                 =>  p_pcx_attribute7
      ,p_pcx_attribute8                 =>  p_pcx_attribute8
      ,p_pcx_attribute9                 =>  p_pcx_attribute9
      ,p_pcx_attribute10                =>  p_pcx_attribute10
      ,p_pcx_attribute11                =>  p_pcx_attribute11
      ,p_pcx_attribute12                =>  p_pcx_attribute12
      ,p_pcx_attribute13                =>  p_pcx_attribute13
      ,p_pcx_attribute14                =>  p_pcx_attribute14
      ,p_pcx_attribute15                =>  p_pcx_attribute15
      ,p_pcx_attribute16                =>  p_pcx_attribute16
      ,p_pcx_attribute17                =>  p_pcx_attribute17
      ,p_pcx_attribute18                =>  p_pcx_attribute18
      ,p_pcx_attribute19                =>  p_pcx_attribute19
      ,p_pcx_attribute20                =>  p_pcx_attribute20
      ,p_pcx_attribute21                =>  p_pcx_attribute21
      ,p_pcx_attribute22                =>  p_pcx_attribute22
      ,p_pcx_attribute23                =>  p_pcx_attribute23
      ,p_pcx_attribute24                =>  p_pcx_attribute24
      ,p_pcx_attribute25                =>  p_pcx_attribute25
      ,p_pcx_attribute26                =>  p_pcx_attribute26
      ,p_pcx_attribute27                =>  p_pcx_attribute27
      ,p_pcx_attribute28                =>  p_pcx_attribute28
      ,p_pcx_attribute29                =>  p_pcx_attribute29
      ,p_pcx_attribute30                =>  p_pcx_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan_Beneficiary_Ctfn
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
  p_pl_bnf_ctfn_id := l_pl_bnf_ctfn_id;
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
    ROLLBACK TO create_Plan_Beneficiary_Ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_bnf_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Plan_Beneficiary_Ctfn;
    raise;
    --
    p_pl_bnf_ctfn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    --
end create_Plan_Beneficiary_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_Beneficiary_Ctfn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Beneficiary_Ctfn
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_ctfn_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_bnf_ctfn_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_sspnd_enrt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_pfd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_bnf_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcx_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcx_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_Beneficiary_Ctfn';
  l_object_version_number ben_pl_bnf_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Plan_Beneficiary_Ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk2.update_Plan_Beneficiary_Ctfn_b
      (
       p_pl_bnf_ctfn_id                 =>  p_pl_bnf_ctfn_id
      ,p_pl_id                          =>  p_pl_id
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_bnf_typ_cd                     =>  p_bnf_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcx_attribute_category         =>  p_pcx_attribute_category
      ,p_pcx_attribute1                 =>  p_pcx_attribute1
      ,p_pcx_attribute2                 =>  p_pcx_attribute2
      ,p_pcx_attribute3                 =>  p_pcx_attribute3
      ,p_pcx_attribute4                 =>  p_pcx_attribute4
      ,p_pcx_attribute5                 =>  p_pcx_attribute5
      ,p_pcx_attribute6                 =>  p_pcx_attribute6
      ,p_pcx_attribute7                 =>  p_pcx_attribute7
      ,p_pcx_attribute8                 =>  p_pcx_attribute8
      ,p_pcx_attribute9                 =>  p_pcx_attribute9
      ,p_pcx_attribute10                =>  p_pcx_attribute10
      ,p_pcx_attribute11                =>  p_pcx_attribute11
      ,p_pcx_attribute12                =>  p_pcx_attribute12
      ,p_pcx_attribute13                =>  p_pcx_attribute13
      ,p_pcx_attribute14                =>  p_pcx_attribute14
      ,p_pcx_attribute15                =>  p_pcx_attribute15
      ,p_pcx_attribute16                =>  p_pcx_attribute16
      ,p_pcx_attribute17                =>  p_pcx_attribute17
      ,p_pcx_attribute18                =>  p_pcx_attribute18
      ,p_pcx_attribute19                =>  p_pcx_attribute19
      ,p_pcx_attribute20                =>  p_pcx_attribute20
      ,p_pcx_attribute21                =>  p_pcx_attribute21
      ,p_pcx_attribute22                =>  p_pcx_attribute22
      ,p_pcx_attribute23                =>  p_pcx_attribute23
      ,p_pcx_attribute24                =>  p_pcx_attribute24
      ,p_pcx_attribute25                =>  p_pcx_attribute25
      ,p_pcx_attribute26                =>  p_pcx_attribute26
      ,p_pcx_attribute27                =>  p_pcx_attribute27
      ,p_pcx_attribute28                =>  p_pcx_attribute28
      ,p_pcx_attribute29                =>  p_pcx_attribute29
      ,p_pcx_attribute30                =>  p_pcx_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan_Beneficiary_Ctfn
    --
  end;
  --
  ben_pcx_upd.upd
    (
     p_pl_bnf_ctfn_id                => p_pl_bnf_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_id                         => p_pl_id
    ,p_bnf_ctfn_typ_cd               => p_bnf_ctfn_typ_cd
    ,p_lack_ctfn_sspnd_enrt_flag     => p_lack_ctfn_sspnd_enrt_flag
    ,p_pfd_flag                      => p_pfd_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_ctfn_rqd_when_rl              => p_ctfn_rqd_when_rl
    ,p_bnf_typ_cd                    => p_bnf_typ_cd
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_pcx_attribute_category        => p_pcx_attribute_category
    ,p_pcx_attribute1                => p_pcx_attribute1
    ,p_pcx_attribute2                => p_pcx_attribute2
    ,p_pcx_attribute3                => p_pcx_attribute3
    ,p_pcx_attribute4                => p_pcx_attribute4
    ,p_pcx_attribute5                => p_pcx_attribute5
    ,p_pcx_attribute6                => p_pcx_attribute6
    ,p_pcx_attribute7                => p_pcx_attribute7
    ,p_pcx_attribute8                => p_pcx_attribute8
    ,p_pcx_attribute9                => p_pcx_attribute9
    ,p_pcx_attribute10               => p_pcx_attribute10
    ,p_pcx_attribute11               => p_pcx_attribute11
    ,p_pcx_attribute12               => p_pcx_attribute12
    ,p_pcx_attribute13               => p_pcx_attribute13
    ,p_pcx_attribute14               => p_pcx_attribute14
    ,p_pcx_attribute15               => p_pcx_attribute15
    ,p_pcx_attribute16               => p_pcx_attribute16
    ,p_pcx_attribute17               => p_pcx_attribute17
    ,p_pcx_attribute18               => p_pcx_attribute18
    ,p_pcx_attribute19               => p_pcx_attribute19
    ,p_pcx_attribute20               => p_pcx_attribute20
    ,p_pcx_attribute21               => p_pcx_attribute21
    ,p_pcx_attribute22               => p_pcx_attribute22
    ,p_pcx_attribute23               => p_pcx_attribute23
    ,p_pcx_attribute24               => p_pcx_attribute24
    ,p_pcx_attribute25               => p_pcx_attribute25
    ,p_pcx_attribute26               => p_pcx_attribute26
    ,p_pcx_attribute27               => p_pcx_attribute27
    ,p_pcx_attribute28               => p_pcx_attribute28
    ,p_pcx_attribute29               => p_pcx_attribute29
    ,p_pcx_attribute30               => p_pcx_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk2.update_Plan_Beneficiary_Ctfn_a
      (
       p_pl_bnf_ctfn_id                 =>  p_pl_bnf_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_id                          =>  p_pl_id
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_lack_ctfn_sspnd_enrt_flag      =>  p_lack_ctfn_sspnd_enrt_flag
      ,p_pfd_flag                       =>  p_pfd_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_ctfn_rqd_when_rl               =>  p_ctfn_rqd_when_rl
      ,p_bnf_typ_cd                     =>  p_bnf_typ_cd
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcx_attribute_category         =>  p_pcx_attribute_category
      ,p_pcx_attribute1                 =>  p_pcx_attribute1
      ,p_pcx_attribute2                 =>  p_pcx_attribute2
      ,p_pcx_attribute3                 =>  p_pcx_attribute3
      ,p_pcx_attribute4                 =>  p_pcx_attribute4
      ,p_pcx_attribute5                 =>  p_pcx_attribute5
      ,p_pcx_attribute6                 =>  p_pcx_attribute6
      ,p_pcx_attribute7                 =>  p_pcx_attribute7
      ,p_pcx_attribute8                 =>  p_pcx_attribute8
      ,p_pcx_attribute9                 =>  p_pcx_attribute9
      ,p_pcx_attribute10                =>  p_pcx_attribute10
      ,p_pcx_attribute11                =>  p_pcx_attribute11
      ,p_pcx_attribute12                =>  p_pcx_attribute12
      ,p_pcx_attribute13                =>  p_pcx_attribute13
      ,p_pcx_attribute14                =>  p_pcx_attribute14
      ,p_pcx_attribute15                =>  p_pcx_attribute15
      ,p_pcx_attribute16                =>  p_pcx_attribute16
      ,p_pcx_attribute17                =>  p_pcx_attribute17
      ,p_pcx_attribute18                =>  p_pcx_attribute18
      ,p_pcx_attribute19                =>  p_pcx_attribute19
      ,p_pcx_attribute20                =>  p_pcx_attribute20
      ,p_pcx_attribute21                =>  p_pcx_attribute21
      ,p_pcx_attribute22                =>  p_pcx_attribute22
      ,p_pcx_attribute23                =>  p_pcx_attribute23
      ,p_pcx_attribute24                =>  p_pcx_attribute24
      ,p_pcx_attribute25                =>  p_pcx_attribute25
      ,p_pcx_attribute26                =>  p_pcx_attribute26
      ,p_pcx_attribute27                =>  p_pcx_attribute27
      ,p_pcx_attribute28                =>  p_pcx_attribute28
      ,p_pcx_attribute29                =>  p_pcx_attribute29
      ,p_pcx_attribute30                =>  p_pcx_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan_Beneficiary_Ctfn
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
    ROLLBACK TO update_Plan_Beneficiary_Ctfn;
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
    ROLLBACK TO update_Plan_Beneficiary_Ctfn;
    raise;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    --
end update_Plan_Beneficiary_Ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_Beneficiary_Ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Beneficiary_Ctfn
  (p_validate                       in  boolean  default false
  ,p_pl_bnf_ctfn_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_Beneficiary_Ctfn';
  l_object_version_number ben_pl_bnf_ctfn_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Plan_Beneficiary_Ctfn;
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
    -- Start of API User Hook for the before hook of delete_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk3.delete_Plan_Beneficiary_Ctfn_b
      (
       p_pl_bnf_ctfn_id                 =>  p_pl_bnf_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan_Beneficiary_Ctfn
    --
  end;
  --
  ben_pcx_del.del
    (
     p_pl_bnf_ctfn_id                => p_pl_bnf_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan_Beneficiary_Ctfn
    --
    ben_Plan_Beneficiary_Ctfn_bk3.delete_Plan_Beneficiary_Ctfn_a
      (
       p_pl_bnf_ctfn_id                 =>  p_pl_bnf_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_Beneficiary_Ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan_Beneficiary_Ctfn
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
    ROLLBACK TO delete_Plan_Beneficiary_Ctfn;
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
    ROLLBACK TO delete_Plan_Beneficiary_Ctfn;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end delete_Plan_Beneficiary_Ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_bnf_ctfn_id                   in     number
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
  ben_pcx_shd.lck
    (
      p_pl_bnf_ctfn_id                 => p_pl_bnf_ctfn_id
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
end ben_Plan_Beneficiary_Ctfn_api;

/
