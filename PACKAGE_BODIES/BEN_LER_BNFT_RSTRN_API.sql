--------------------------------------------------------
--  DDL for Package Body BEN_LER_BNFT_RSTRN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_BNFT_RSTRN_API" as
/* $Header: belbrapi.pkb 120.0 2005/05/28 03:16:12 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_LER_BNFT_RSTRN_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_LER_BNFT_RSTRN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_LER_BNFT_RSTRN
  (p_validate                       in  boolean   default false
  ,p_ler_bnft_rstrn_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default null
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default null
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default null
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default null
  ,p_mx_cvg_incr_alwd_amt           in  number    default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_cvg_mlt_incr_num            in  number    default null
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default null
  ,p_mx_cvg_rl                      in  number    default null
  ,p_mx_cvg_wcfn_amt                in  number    default null
  ,p_mx_cvg_wcfn_mlt_num            in  number    default null
  ,p_mn_cvg_amt                     in  number    default null
  ,p_mn_cvg_rl                      in  number    default null
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default null
  ,p_unsspnd_enrt_cd                in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_lbr_attribute_category         in  varchar2  default null
  ,p_lbr_attribute1                 in  varchar2  default null
  ,p_lbr_attribute2                 in  varchar2  default null
  ,p_lbr_attribute3                 in  varchar2  default null
  ,p_lbr_attribute4                 in  varchar2  default null
  ,p_lbr_attribute5                 in  varchar2  default null
  ,p_lbr_attribute6                 in  varchar2  default null
  ,p_lbr_attribute7                 in  varchar2  default null
  ,p_lbr_attribute8                 in  varchar2  default null
  ,p_lbr_attribute9                 in  varchar2  default null
  ,p_lbr_attribute10                in  varchar2  default null
  ,p_lbr_attribute11                in  varchar2  default null
  ,p_lbr_attribute12                in  varchar2  default null
  ,p_lbr_attribute13                in  varchar2  default null
  ,p_lbr_attribute14                in  varchar2  default null
  ,p_lbr_attribute15                in  varchar2  default null
  ,p_lbr_attribute16                in  varchar2  default null
  ,p_lbr_attribute17                in  varchar2  default null
  ,p_lbr_attribute18                in  varchar2  default null
  ,p_lbr_attribute19                in  varchar2  default null
  ,p_lbr_attribute20                in  varchar2  default null
  ,p_lbr_attribute21                in  varchar2  default null
  ,p_lbr_attribute22                in  varchar2  default null
  ,p_lbr_attribute23                in  varchar2  default null
  ,p_lbr_attribute24                in  varchar2  default null
  ,p_lbr_attribute25                in  varchar2  default null
  ,p_lbr_attribute26                in  varchar2  default null
  ,p_lbr_attribute27                in  varchar2  default null
  ,p_lbr_attribute28                in  varchar2  default null
  ,p_lbr_attribute29                in  varchar2  default null
  ,p_lbr_attribute30                in  varchar2  default null
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_bnft_rstrn_id ben_ler_bnft_rstrn_f.ler_bnft_rstrn_id%TYPE;
  l_effective_start_date ben_ler_bnft_rstrn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_bnft_rstrn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_LER_BNFT_RSTRN';
  l_object_version_number ben_ler_bnft_rstrn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_LER_BNFT_RSTRN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk1.create_LER_BNFT_RSTRN_b
      (
       p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_plip_id                        =>  p_plip_id
      ,p_lbr_attribute_category         =>  p_lbr_attribute_category
      ,p_lbr_attribute1                 =>  p_lbr_attribute1
      ,p_lbr_attribute2                 =>  p_lbr_attribute2
      ,p_lbr_attribute3                 =>  p_lbr_attribute3
      ,p_lbr_attribute4                 =>  p_lbr_attribute4
      ,p_lbr_attribute5                 =>  p_lbr_attribute5
      ,p_lbr_attribute6                 =>  p_lbr_attribute6
      ,p_lbr_attribute7                 =>  p_lbr_attribute7
      ,p_lbr_attribute8                 =>  p_lbr_attribute8
      ,p_lbr_attribute9                 =>  p_lbr_attribute9
      ,p_lbr_attribute10                =>  p_lbr_attribute10
      ,p_lbr_attribute11                =>  p_lbr_attribute11
      ,p_lbr_attribute12                =>  p_lbr_attribute12
      ,p_lbr_attribute13                =>  p_lbr_attribute13
      ,p_lbr_attribute14                =>  p_lbr_attribute14
      ,p_lbr_attribute15                =>  p_lbr_attribute15
      ,p_lbr_attribute16                =>  p_lbr_attribute16
      ,p_lbr_attribute17                =>  p_lbr_attribute17
      ,p_lbr_attribute18                =>  p_lbr_attribute18
      ,p_lbr_attribute19                =>  p_lbr_attribute19
      ,p_lbr_attribute20                =>  p_lbr_attribute20
      ,p_lbr_attribute21                =>  p_lbr_attribute21
      ,p_lbr_attribute22                =>  p_lbr_attribute22
      ,p_lbr_attribute23                =>  p_lbr_attribute23
      ,p_lbr_attribute24                =>  p_lbr_attribute24
      ,p_lbr_attribute25                =>  p_lbr_attribute25
      ,p_lbr_attribute26                =>  p_lbr_attribute26
      ,p_lbr_attribute27                =>  p_lbr_attribute27
      ,p_lbr_attribute28                =>  p_lbr_attribute28
      ,p_lbr_attribute29                =>  p_lbr_attribute29
      ,p_lbr_attribute30                =>  p_lbr_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_LER_BNFT_RSTRN
    --
  end;
  --
  ben_lbr_ins.ins
    (
     p_ler_bnft_rstrn_id             => l_ler_bnft_rstrn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_mn_cvg_amt                    => p_mn_cvg_amt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_ler_id                        => p_ler_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_plip_id                       => p_plip_id
    ,p_lbr_attribute_category        => p_lbr_attribute_category
    ,p_lbr_attribute1                => p_lbr_attribute1
    ,p_lbr_attribute2                => p_lbr_attribute2
    ,p_lbr_attribute3                => p_lbr_attribute3
    ,p_lbr_attribute4                => p_lbr_attribute4
    ,p_lbr_attribute5                => p_lbr_attribute5
    ,p_lbr_attribute6                => p_lbr_attribute6
    ,p_lbr_attribute7                => p_lbr_attribute7
    ,p_lbr_attribute8                => p_lbr_attribute8
    ,p_lbr_attribute9                => p_lbr_attribute9
    ,p_lbr_attribute10               => p_lbr_attribute10
    ,p_lbr_attribute11               => p_lbr_attribute11
    ,p_lbr_attribute12               => p_lbr_attribute12
    ,p_lbr_attribute13               => p_lbr_attribute13
    ,p_lbr_attribute14               => p_lbr_attribute14
    ,p_lbr_attribute15               => p_lbr_attribute15
    ,p_lbr_attribute16               => p_lbr_attribute16
    ,p_lbr_attribute17               => p_lbr_attribute17
    ,p_lbr_attribute18               => p_lbr_attribute18
    ,p_lbr_attribute19               => p_lbr_attribute19
    ,p_lbr_attribute20               => p_lbr_attribute20
    ,p_lbr_attribute21               => p_lbr_attribute21
    ,p_lbr_attribute22               => p_lbr_attribute22
    ,p_lbr_attribute23               => p_lbr_attribute23
    ,p_lbr_attribute24               => p_lbr_attribute24
    ,p_lbr_attribute25               => p_lbr_attribute25
    ,p_lbr_attribute26               => p_lbr_attribute26
    ,p_lbr_attribute27               => p_lbr_attribute27
    ,p_lbr_attribute28               => p_lbr_attribute28
    ,p_lbr_attribute29               => p_lbr_attribute29
    ,p_lbr_attribute30               => p_lbr_attribute30
    ,p_susp_if_ctfn_not_prvd_flag    => p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             => p_ctfn_determine_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk1.create_LER_BNFT_RSTRN_a
      (
       p_ler_bnft_rstrn_id              =>  l_ler_bnft_rstrn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_plip_id                        =>  p_plip_id
      ,p_lbr_attribute_category         =>  p_lbr_attribute_category
      ,p_lbr_attribute1                 =>  p_lbr_attribute1
      ,p_lbr_attribute2                 =>  p_lbr_attribute2
      ,p_lbr_attribute3                 =>  p_lbr_attribute3
      ,p_lbr_attribute4                 =>  p_lbr_attribute4
      ,p_lbr_attribute5                 =>  p_lbr_attribute5
      ,p_lbr_attribute6                 =>  p_lbr_attribute6
      ,p_lbr_attribute7                 =>  p_lbr_attribute7
      ,p_lbr_attribute8                 =>  p_lbr_attribute8
      ,p_lbr_attribute9                 =>  p_lbr_attribute9
      ,p_lbr_attribute10                =>  p_lbr_attribute10
      ,p_lbr_attribute11                =>  p_lbr_attribute11
      ,p_lbr_attribute12                =>  p_lbr_attribute12
      ,p_lbr_attribute13                =>  p_lbr_attribute13
      ,p_lbr_attribute14                =>  p_lbr_attribute14
      ,p_lbr_attribute15                =>  p_lbr_attribute15
      ,p_lbr_attribute16                =>  p_lbr_attribute16
      ,p_lbr_attribute17                =>  p_lbr_attribute17
      ,p_lbr_attribute18                =>  p_lbr_attribute18
      ,p_lbr_attribute19                =>  p_lbr_attribute19
      ,p_lbr_attribute20                =>  p_lbr_attribute20
      ,p_lbr_attribute21                =>  p_lbr_attribute21
      ,p_lbr_attribute22                =>  p_lbr_attribute22
      ,p_lbr_attribute23                =>  p_lbr_attribute23
      ,p_lbr_attribute24                =>  p_lbr_attribute24
      ,p_lbr_attribute25                =>  p_lbr_attribute25
      ,p_lbr_attribute26                =>  p_lbr_attribute26
      ,p_lbr_attribute27                =>  p_lbr_attribute27
      ,p_lbr_attribute28                =>  p_lbr_attribute28
      ,p_lbr_attribute29                =>  p_lbr_attribute29
      ,p_lbr_attribute30                =>  p_lbr_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_LER_BNFT_RSTRN
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
  p_ler_bnft_rstrn_id := l_ler_bnft_rstrn_id;
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
    ROLLBACK TO create_LER_BNFT_RSTRN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_bnft_rstrn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_LER_BNFT_RSTRN;
    raise;
    --
end create_LER_BNFT_RSTRN;
-- ----------------------------------------------------------------------------
-- |------------------------< update_LER_BNFT_RSTRN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_LER_BNFT_RSTRN
  (p_validate                       in  boolean   default false
  ,p_ler_bnft_rstrn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default hr_api.g_number
  ,p_mx_cvg_incr_alwd_amt           in  number    default hr_api.g_number
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_num            in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default hr_api.g_number
  ,p_mx_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_mlt_num            in  number    default hr_api.g_number
  ,p_mn_cvg_amt                     in  number    default hr_api.g_number
  ,p_mn_cvg_rl                      in  number    default hr_api.g_number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default hr_api.g_varchar2
  ,p_unsspnd_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_lbr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LER_BNFT_RSTRN';
  l_object_version_number ben_ler_bnft_rstrn_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_bnft_rstrn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_bnft_rstrn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_LER_BNFT_RSTRN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk2.update_LER_BNFT_RSTRN_b
      (
       p_ler_bnft_rstrn_id              =>  p_ler_bnft_rstrn_id
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_plip_id                        =>  p_plip_id
      ,p_lbr_attribute_category         =>  p_lbr_attribute_category
      ,p_lbr_attribute1                 =>  p_lbr_attribute1
      ,p_lbr_attribute2                 =>  p_lbr_attribute2
      ,p_lbr_attribute3                 =>  p_lbr_attribute3
      ,p_lbr_attribute4                 =>  p_lbr_attribute4
      ,p_lbr_attribute5                 =>  p_lbr_attribute5
      ,p_lbr_attribute6                 =>  p_lbr_attribute6
      ,p_lbr_attribute7                 =>  p_lbr_attribute7
      ,p_lbr_attribute8                 =>  p_lbr_attribute8
      ,p_lbr_attribute9                 =>  p_lbr_attribute9
      ,p_lbr_attribute10                =>  p_lbr_attribute10
      ,p_lbr_attribute11                =>  p_lbr_attribute11
      ,p_lbr_attribute12                =>  p_lbr_attribute12
      ,p_lbr_attribute13                =>  p_lbr_attribute13
      ,p_lbr_attribute14                =>  p_lbr_attribute14
      ,p_lbr_attribute15                =>  p_lbr_attribute15
      ,p_lbr_attribute16                =>  p_lbr_attribute16
      ,p_lbr_attribute17                =>  p_lbr_attribute17
      ,p_lbr_attribute18                =>  p_lbr_attribute18
      ,p_lbr_attribute19                =>  p_lbr_attribute19
      ,p_lbr_attribute20                =>  p_lbr_attribute20
      ,p_lbr_attribute21                =>  p_lbr_attribute21
      ,p_lbr_attribute22                =>  p_lbr_attribute22
      ,p_lbr_attribute23                =>  p_lbr_attribute23
      ,p_lbr_attribute24                =>  p_lbr_attribute24
      ,p_lbr_attribute25                =>  p_lbr_attribute25
      ,p_lbr_attribute26                =>  p_lbr_attribute26
      ,p_lbr_attribute27                =>  p_lbr_attribute27
      ,p_lbr_attribute28                =>  p_lbr_attribute28
      ,p_lbr_attribute29                =>  p_lbr_attribute29
      ,p_lbr_attribute30                =>  p_lbr_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_LER_BNFT_RSTRN
    --
  end;
  --
  ben_lbr_upd.upd
    (
     p_ler_bnft_rstrn_id             => p_ler_bnft_rstrn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_mn_cvg_amt                    => p_mn_cvg_amt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_ler_id                        => p_ler_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_plip_id                       => p_plip_id
    ,p_lbr_attribute_category        => p_lbr_attribute_category
    ,p_lbr_attribute1                => p_lbr_attribute1
    ,p_lbr_attribute2                => p_lbr_attribute2
    ,p_lbr_attribute3                => p_lbr_attribute3
    ,p_lbr_attribute4                => p_lbr_attribute4
    ,p_lbr_attribute5                => p_lbr_attribute5
    ,p_lbr_attribute6                => p_lbr_attribute6
    ,p_lbr_attribute7                => p_lbr_attribute7
    ,p_lbr_attribute8                => p_lbr_attribute8
    ,p_lbr_attribute9                => p_lbr_attribute9
    ,p_lbr_attribute10               => p_lbr_attribute10
    ,p_lbr_attribute11               => p_lbr_attribute11
    ,p_lbr_attribute12               => p_lbr_attribute12
    ,p_lbr_attribute13               => p_lbr_attribute13
    ,p_lbr_attribute14               => p_lbr_attribute14
    ,p_lbr_attribute15               => p_lbr_attribute15
    ,p_lbr_attribute16               => p_lbr_attribute16
    ,p_lbr_attribute17               => p_lbr_attribute17
    ,p_lbr_attribute18               => p_lbr_attribute18
    ,p_lbr_attribute19               => p_lbr_attribute19
    ,p_lbr_attribute20               => p_lbr_attribute20
    ,p_lbr_attribute21               => p_lbr_attribute21
    ,p_lbr_attribute22               => p_lbr_attribute22
    ,p_lbr_attribute23               => p_lbr_attribute23
    ,p_lbr_attribute24               => p_lbr_attribute24
    ,p_lbr_attribute25               => p_lbr_attribute25
    ,p_lbr_attribute26               => p_lbr_attribute26
    ,p_lbr_attribute27               => p_lbr_attribute27
    ,p_lbr_attribute28               => p_lbr_attribute28
    ,p_lbr_attribute29               => p_lbr_attribute29
    ,p_lbr_attribute30               => p_lbr_attribute30
    ,p_susp_if_ctfn_not_prvd_flag    => p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             => p_ctfn_determine_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk2.update_LER_BNFT_RSTRN_a
      (
       p_ler_bnft_rstrn_id              =>  p_ler_bnft_rstrn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_plip_id                        =>  p_plip_id
      ,p_lbr_attribute_category         =>  p_lbr_attribute_category
      ,p_lbr_attribute1                 =>  p_lbr_attribute1
      ,p_lbr_attribute2                 =>  p_lbr_attribute2
      ,p_lbr_attribute3                 =>  p_lbr_attribute3
      ,p_lbr_attribute4                 =>  p_lbr_attribute4
      ,p_lbr_attribute5                 =>  p_lbr_attribute5
      ,p_lbr_attribute6                 =>  p_lbr_attribute6
      ,p_lbr_attribute7                 =>  p_lbr_attribute7
      ,p_lbr_attribute8                 =>  p_lbr_attribute8
      ,p_lbr_attribute9                 =>  p_lbr_attribute9
      ,p_lbr_attribute10                =>  p_lbr_attribute10
      ,p_lbr_attribute11                =>  p_lbr_attribute11
      ,p_lbr_attribute12                =>  p_lbr_attribute12
      ,p_lbr_attribute13                =>  p_lbr_attribute13
      ,p_lbr_attribute14                =>  p_lbr_attribute14
      ,p_lbr_attribute15                =>  p_lbr_attribute15
      ,p_lbr_attribute16                =>  p_lbr_attribute16
      ,p_lbr_attribute17                =>  p_lbr_attribute17
      ,p_lbr_attribute18                =>  p_lbr_attribute18
      ,p_lbr_attribute19                =>  p_lbr_attribute19
      ,p_lbr_attribute20                =>  p_lbr_attribute20
      ,p_lbr_attribute21                =>  p_lbr_attribute21
      ,p_lbr_attribute22                =>  p_lbr_attribute22
      ,p_lbr_attribute23                =>  p_lbr_attribute23
      ,p_lbr_attribute24                =>  p_lbr_attribute24
      ,p_lbr_attribute25                =>  p_lbr_attribute25
      ,p_lbr_attribute26                =>  p_lbr_attribute26
      ,p_lbr_attribute27                =>  p_lbr_attribute27
      ,p_lbr_attribute28                =>  p_lbr_attribute28
      ,p_lbr_attribute29                =>  p_lbr_attribute29
      ,p_lbr_attribute30                =>  p_lbr_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_LER_BNFT_RSTRN
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
    ROLLBACK TO update_LER_BNFT_RSTRN;
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
    ROLLBACK TO update_LER_BNFT_RSTRN;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_LER_BNFT_RSTRN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_LER_BNFT_RSTRN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LER_BNFT_RSTRN
  (p_validate                       in  boolean  default false
  ,p_ler_bnft_rstrn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LER_BNFT_RSTRN';
  l_object_version_number ben_ler_bnft_rstrn_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_bnft_rstrn_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_bnft_rstrn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_LER_BNFT_RSTRN;
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
    -- Start of API User Hook for the before hook of delete_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk3.delete_LER_BNFT_RSTRN_b
      (
       p_ler_bnft_rstrn_id              =>  p_ler_bnft_rstrn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_LER_BNFT_RSTRN
    --
  end;
  --
  ben_lbr_del.del
    (
     p_ler_bnft_rstrn_id             => p_ler_bnft_rstrn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_LER_BNFT_RSTRN
    --
    ben_LER_BNFT_RSTRN_bk3.delete_LER_BNFT_RSTRN_a
      (
       p_ler_bnft_rstrn_id              =>  p_ler_bnft_rstrn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LER_BNFT_RSTRN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_LER_BNFT_RSTRN
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
    ROLLBACK TO delete_LER_BNFT_RSTRN;
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
    ROLLBACK TO delete_LER_BNFT_RSTRN;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_LER_BNFT_RSTRN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_bnft_rstrn_id                   in     number
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
  ben_lbr_shd.lck
    (
      p_ler_bnft_rstrn_id                 => p_ler_bnft_rstrn_id
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
end ben_LER_BNFT_RSTRN_api;

/
