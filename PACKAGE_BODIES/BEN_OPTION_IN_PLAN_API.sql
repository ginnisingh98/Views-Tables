--------------------------------------------------------
--  DDL for Package Body BEN_OPTION_IN_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPTION_IN_PLAN_API" as
/* $Header: becopapi.pkb 120.0.12010000.2 2008/08/05 14:18:26 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Option_in_Plan_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Option_in_Plan >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Option_in_Plan
  (p_validate                       in  boolean   default false
  ,p_oipl_id                        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ivr_ident                      in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_opt_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_rqd_perd_enrt_nenrt_val                       in  number    default null
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_actl_prem_id                   in  number    default null
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_oipl_stat_cd                   in  varchar2  default null
  ,p_pcp_dsgn_cd                    in  varchar2  default null
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default null
  ,p_rqd_perd_enrt_nenrt_uom                   in  varchar2  default null
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_dflt_enrt_det_rl               in  number    default null
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_mndtry_rl                      in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl                      in  number    default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_postelcn_edit_rl               in  number    default null
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_rl              in  number    default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_short_name                     in  varchar2  default null   /*FHR*/
  ,p_short_code                     in  varchar2  default null   /*FHR*/
    ,p_legislation_code                     in  varchar2  default null   /*FHR*/
    ,p_legislation_subgroup                     in  varchar2  default null   /*FHR*/
  ,p_hidden_flag                    in  varchar2  default 'N'
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_cop_attribute_category         in  varchar2  default null
  ,p_cop_attribute1                 in  varchar2  default null
  ,p_cop_attribute2                 in  varchar2  default null
  ,p_cop_attribute3                 in  varchar2  default null
  ,p_cop_attribute4                 in  varchar2  default null
  ,p_cop_attribute5                 in  varchar2  default null
  ,p_cop_attribute6                 in  varchar2  default null
  ,p_cop_attribute7                 in  varchar2  default null
  ,p_cop_attribute8                 in  varchar2  default null
  ,p_cop_attribute9                 in  varchar2  default null
  ,p_cop_attribute10                in  varchar2  default null
  ,p_cop_attribute11                in  varchar2  default null
  ,p_cop_attribute12                in  varchar2  default null
  ,p_cop_attribute13                in  varchar2  default null
  ,p_cop_attribute14                in  varchar2  default null
  ,p_cop_attribute15                in  varchar2  default null
  ,p_cop_attribute16                in  varchar2  default null
  ,p_cop_attribute17                in  varchar2  default null
  ,p_cop_attribute18                in  varchar2  default null
  ,p_cop_attribute19                in  varchar2  default null
  ,p_cop_attribute20                in  varchar2  default null
  ,p_cop_attribute21                in  varchar2  default null
  ,p_cop_attribute22                in  varchar2  default null
  ,p_cop_attribute23                in  varchar2  default null
  ,p_cop_attribute24                in  varchar2  default null
  ,p_cop_attribute25                in  varchar2  default null
  ,p_cop_attribute26                in  varchar2  default null
  ,p_cop_attribute27                in  varchar2  default null
  ,p_cop_attribute28                in  varchar2  default null
  ,p_cop_attribute29                in  varchar2  default null
  ,p_cop_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  cursor c_cpp is
     select cpp.plip_id
     from   ben_plip_f cpp
     where  cpp.pl_id = p_pl_id
     and    cpp.business_group_id + 0 = p_business_group_id
     and    p_effective_date between
            cpp.effective_start_date and cpp.effective_end_date;
  --
  cursor c_otp is
    select
      plip.pgm_id,
      pl.pl_typ_id,
      ptip.ptip_id
    from
      ben_ptip_f ptip,
      ben_plip_f plip,
      ben_pl_f pl
    where
        pl.pl_id = p_pl_id
    and plip.pl_id = pl.pl_id
    and pl.business_group_id = p_business_group_id
    and plip.business_group_id = p_business_group_id
    and plip.pgm_id = ptip.pgm_id
    and pl.pl_typ_id = ptip.pl_typ_id
    and p_effective_date between  plip.effective_start_date and  plip.effective_end_date
    and p_effective_date between   pl.effective_start_date and   pl.effective_end_date
    and p_effective_date between ptip.effective_start_date and ptip.effective_end_date ;

  l_oipl_id                   ben_oipl_f.oipl_id%TYPE;
  l_effective_start_date      ben_oipl_f.effective_start_date%TYPE;
  l_effective_end_date        ben_oipl_f.effective_end_date%TYPE;
  l_proc                      varchar2(72) := g_package||
                                              'create_Option_in_Plan';
  l_object_version_number     ben_oipl_f.object_version_number%TYPE;
  --
  l_oiplip_id                 ben_oiplip_f.oiplip_id%type;
  l_opp_effective_start_date  ben_oiplip_f.effective_start_date%type;
  l_opp_effective_end_date    ben_oiplip_f.effective_end_date%type;
  l_opp_object_version_number ben_oiplip_f.object_version_number%type;
  -- ben_optip_f
  l_optip_id                  ben_optip_f.optip_id%type;
  l_otp_effective_start_date  ben_optip_f.effective_start_date%type;
  l_otp_effective_end_date    ben_optip_f.effective_end_date%type;
  l_otp_object_version_number ben_optip_f.object_version_number%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Option_in_Plan;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Option_in_Plan
    --
    ben_Option_in_Plan_bk1.create_Option_in_Plan_b
      (p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_opt_id                         =>  p_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_oipl_stat_cd                   =>  p_oipl_stat_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_rqd_perd_enrt_nenrt_uom                   =>  p_rqd_perd_enrt_nenrt_uom
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_mndtry_rl                      =>  p_mndtry_rl
      ,p_rqd_perd_enrt_nenrt_rl                      =>  p_rqd_perd_enrt_nenrt_rl
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_short_name     		=>  p_short_name		/*FHR*/
      ,p_short_code     		=>  p_short_code		/*FHR*/
            ,p_legislation_code     		=>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup     		=>  p_legislation_subgroup		/*FHR*/
      ,p_hidden_flag     		=>  p_hidden_flag
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_cop_attribute_category         =>  p_cop_attribute_category
      ,p_cop_attribute1                 =>  p_cop_attribute1
      ,p_cop_attribute2                 =>  p_cop_attribute2
      ,p_cop_attribute3                 =>  p_cop_attribute3
      ,p_cop_attribute4                 =>  p_cop_attribute4
      ,p_cop_attribute5                 =>  p_cop_attribute5
      ,p_cop_attribute6                 =>  p_cop_attribute6
      ,p_cop_attribute7                 =>  p_cop_attribute7
      ,p_cop_attribute8                 =>  p_cop_attribute8
      ,p_cop_attribute9                 =>  p_cop_attribute9
      ,p_cop_attribute10                =>  p_cop_attribute10
      ,p_cop_attribute11                =>  p_cop_attribute11
      ,p_cop_attribute12                =>  p_cop_attribute12
      ,p_cop_attribute13                =>  p_cop_attribute13
      ,p_cop_attribute14                =>  p_cop_attribute14
      ,p_cop_attribute15                =>  p_cop_attribute15
      ,p_cop_attribute16                =>  p_cop_attribute16
      ,p_cop_attribute17                =>  p_cop_attribute17
      ,p_cop_attribute18                =>  p_cop_attribute18
      ,p_cop_attribute19                =>  p_cop_attribute19
      ,p_cop_attribute20                =>  p_cop_attribute20
      ,p_cop_attribute21                =>  p_cop_attribute21
      ,p_cop_attribute22                =>  p_cop_attribute22
      ,p_cop_attribute23                =>  p_cop_attribute23
      ,p_cop_attribute24                =>  p_cop_attribute24
      ,p_cop_attribute25                =>  p_cop_attribute25
      ,p_cop_attribute26                =>  p_cop_attribute26
      ,p_cop_attribute27                =>  p_cop_attribute27
      ,p_cop_attribute28                =>  p_cop_attribute28
      ,p_cop_attribute29                =>  p_cop_attribute29
      ,p_cop_attribute30                =>  p_cop_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Option_in_Plan'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Option_in_Plan
    --
  end;
  --
  ben_cop_ins.ins
    (p_oipl_id                       => l_oipl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ivr_ident                     => p_ivr_ident
    ,p_url_ref_name                  => p_url_ref_name
    ,p_opt_id                        => p_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_rqd_perd_enrt_nenrt_val       => p_rqd_perd_enrt_nenrt_val
    ,p_dflt_flag                     => p_dflt_flag
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_oipl_stat_cd                  => p_oipl_stat_cd
    ,p_pcp_dsgn_cd                   => p_pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd              => p_pcp_dpnt_dsgn_cd
    ,p_rqd_perd_enrt_nenrt_uom                  => p_rqd_perd_enrt_nenrt_uom
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_dflt_enrt_det_rl              => p_dflt_enrt_det_rl
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_mndtry_rl                     => p_mndtry_rl
    ,p_rqd_perd_enrt_nenrt_rl                     => p_rqd_perd_enrt_nenrt_rl
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_vrfy_fmly_mmbr_cd             => p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl             => p_vrfy_fmly_mmbr_rl
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_rl                       => p_enrt_rl
    ,p_auto_enrt_flag                => p_auto_enrt_flag
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_short_name     		     => p_short_name		/*FHR*/
    ,p_short_code     		     => p_short_code		/*FHR*/
        ,p_legislation_code     		     => p_legislation_code		/*FHR*/
        ,p_legislation_subgroup     		     => p_legislation_subgroup		/*FHR*/
    ,p_hidden_flag     		     => p_hidden_flag
    ,p_susp_if_ctfn_not_prvd_flag    =>  p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             =>  p_ctfn_determine_cd
    ,p_cop_attribute_category        => p_cop_attribute_category
    ,p_cop_attribute1                => p_cop_attribute1
    ,p_cop_attribute2                => p_cop_attribute2
    ,p_cop_attribute3                => p_cop_attribute3
    ,p_cop_attribute4                => p_cop_attribute4
    ,p_cop_attribute5                => p_cop_attribute5
    ,p_cop_attribute6                => p_cop_attribute6
    ,p_cop_attribute7                => p_cop_attribute7
    ,p_cop_attribute8                => p_cop_attribute8
    ,p_cop_attribute9                => p_cop_attribute9
    ,p_cop_attribute10               => p_cop_attribute10
    ,p_cop_attribute11               => p_cop_attribute11
    ,p_cop_attribute12               => p_cop_attribute12
    ,p_cop_attribute13               => p_cop_attribute13
    ,p_cop_attribute14               => p_cop_attribute14
    ,p_cop_attribute15               => p_cop_attribute15
    ,p_cop_attribute16               => p_cop_attribute16
    ,p_cop_attribute17               => p_cop_attribute17
    ,p_cop_attribute18               => p_cop_attribute18
    ,p_cop_attribute19               => p_cop_attribute19
    ,p_cop_attribute20               => p_cop_attribute20
    ,p_cop_attribute21               => p_cop_attribute21
    ,p_cop_attribute22               => p_cop_attribute22
    ,p_cop_attribute23               => p_cop_attribute23
    ,p_cop_attribute24               => p_cop_attribute24
    ,p_cop_attribute25               => p_cop_attribute25
    ,p_cop_attribute26               => p_cop_attribute26
    ,p_cop_attribute27               => p_cop_attribute27
    ,p_cop_attribute28               => p_cop_attribute28
    ,p_cop_attribute29               => p_cop_attribute29
    ,p_cop_attribute30               => p_cop_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Option_in_Plan
    --
    ben_Option_in_Plan_bk1.create_Option_in_Plan_a
      (p_oipl_id                        =>  l_oipl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_opt_id                         =>  p_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_rqd_perd_enrt_nenrt_val                       =>  p_rqd_perd_enrt_nenrt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_oipl_stat_cd                   =>  p_oipl_stat_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_rqd_perd_enrt_nenrt_uom                   =>  p_rqd_perd_enrt_nenrt_uom
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_mndtry_rl                      =>  p_mndtry_rl
      ,p_rqd_perd_enrt_nenrt_rl                      =>  p_rqd_perd_enrt_nenrt_rl
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_short_name     		=>  p_short_name		/*FHR*/
      ,p_short_code     		=>  p_short_code		/*FHR*/
            ,p_legislation_code     		=>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup     		=>  p_legislation_subgroup		/*FHR*/
      ,p_hidden_flag     		=>  p_hidden_flag
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_cop_attribute_category         =>  p_cop_attribute_category
      ,p_cop_attribute1                 =>  p_cop_attribute1
      ,p_cop_attribute2                 =>  p_cop_attribute2
      ,p_cop_attribute3                 =>  p_cop_attribute3
      ,p_cop_attribute4                 =>  p_cop_attribute4
      ,p_cop_attribute5                 =>  p_cop_attribute5
      ,p_cop_attribute6                 =>  p_cop_attribute6
      ,p_cop_attribute7                 =>  p_cop_attribute7
      ,p_cop_attribute8                 =>  p_cop_attribute8
      ,p_cop_attribute9                 =>  p_cop_attribute9
      ,p_cop_attribute10                =>  p_cop_attribute10
      ,p_cop_attribute11                =>  p_cop_attribute11
      ,p_cop_attribute12                =>  p_cop_attribute12
      ,p_cop_attribute13                =>  p_cop_attribute13
      ,p_cop_attribute14                =>  p_cop_attribute14
      ,p_cop_attribute15                =>  p_cop_attribute15
      ,p_cop_attribute16                =>  p_cop_attribute16
      ,p_cop_attribute17                =>  p_cop_attribute17
      ,p_cop_attribute18                =>  p_cop_attribute18
      ,p_cop_attribute19                =>  p_cop_attribute19
      ,p_cop_attribute20                =>  p_cop_attribute20
      ,p_cop_attribute21                =>  p_cop_attribute21
      ,p_cop_attribute22                =>  p_cop_attribute22
      ,p_cop_attribute23                =>  p_cop_attribute23
      ,p_cop_attribute24                =>  p_cop_attribute24
      ,p_cop_attribute25                =>  p_cop_attribute25
      ,p_cop_attribute26                =>  p_cop_attribute26
      ,p_cop_attribute27                =>  p_cop_attribute27
      ,p_cop_attribute28                =>  p_cop_attribute28
      ,p_cop_attribute29                =>  p_cop_attribute29
      ,p_cop_attribute30                =>  p_cop_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Option_in_Plan'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Option_in_Plan
    --
  end;
  --
  for l_cpp in c_cpp loop
    --
    ben_option_in_plan_in_pgm_api.create_option_in_plan_in_pgm(
         p_validate                => false,
         p_oiplip_id               => l_oiplip_id,
         p_effective_start_date    => l_opp_effective_start_date,
         p_effective_end_date      => l_opp_effective_end_date,
         p_oipl_id                 => l_oipl_id,
         p_plip_id                 => l_cpp.plip_id,
         p_business_group_id       => p_business_group_id,
         p_object_version_number   => l_opp_object_version_number,
         p_effective_date          => p_effective_date);
    --
  end loop;
  --
  hr_utility.set_location(l_proc, 60);
  -- bug 1285336
  FOR l_otp IN c_otp LOOP
    --
    hr_utility.set_location('Before entering into create_opt_pltyp_in_pgm ', 65);
    hr_utility.set_location('l_otp.pgm_id '||l_otp.pgm_id , 65.1);
    hr_utility.set_location('l_otp.ptip_id'||l_otp.ptip_id,65.2);
    hr_utility.set_location('l_otp.pl_typ_id'||l_otp.pl_typ_id,65.3);
    --
    ben_opt_pltyp_in_pgm_api.create_opt_pltyp_in_pgm
        (p_validate                      => false
        ,p_optip_id                      =>l_optip_id
        ,p_effective_start_date          =>l_otp_effective_start_date
        ,p_effective_end_date            =>l_otp_effective_end_date
        ,p_business_group_id             =>p_business_group_id
        ,p_pgm_id                        =>l_otp.pgm_id
        ,p_ptip_id                       =>l_otp.ptip_id
        ,p_pl_typ_id                     =>l_otp.pl_typ_id
        ,p_opt_id                        =>p_opt_id
    --  ,p_cmbn_ptip_opt_id              =>p_cmbn_ptip_opt_id
        ,p_object_version_number         =>l_otp_object_version_number
        ,p_effective_date                =>p_effective_date
    );
    hr_utility.set_location('Before entering into create_opt_pltyp_in_pgm ', 66);
  END LOOP ;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_oipl_id := l_oipl_id;
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
    ROLLBACK TO create_Option_in_Plan;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_oipl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Option_in_Plan;
    /* Inserted for nocopy changes */
    p_oipl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_Option_in_Plan;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Option_in_Plan >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Option_in_Plan
  (p_validate                       in  boolean   default false
  ,p_oipl_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_val                       in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_oipl_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dsgn_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pcp_dpnt_dsgn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_det_rl               in  number    default hr_api.g_number
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_rl                      in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl                      in  number    default hr_api.g_number
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
    ,p_legislation_code                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
    ,p_legislation_subgroup                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
  ,p_hidden_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag      in  varchar2   default hr_api.g_varchar2
  ,p_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2
  ,p_cop_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cop_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_Option_in_Plan';
  l_object_version_number ben_oipl_f.object_version_number%TYPE;
  l_effective_start_date  ben_oipl_f.effective_start_date%TYPE;
  l_effective_end_date    ben_oipl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Option_in_Plan;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Option_in_Plan
    --
    ben_Option_in_Plan_bk2.update_Option_in_Plan_b
      (p_oipl_id                        =>  p_oipl_id
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_opt_id                         =>  p_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_rqd_perd_enrt_nenrt_val                       =>  p_rqd_perd_enrt_nenrt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_oipl_stat_cd                   =>  p_oipl_stat_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_rqd_perd_enrt_nenrt_uom                   =>  p_rqd_perd_enrt_nenrt_uom
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_mndtry_rl                      =>  p_mndtry_rl
      ,p_rqd_perd_enrt_nenrt_rl                      =>  p_rqd_perd_enrt_nenrt_rl
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_short_name  			=>  p_short_name		/*FHR*/
      ,p_short_code		        =>  p_short_code		/*FHR*/
            ,p_legislation_code		        =>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup		        =>  p_legislation_subgroup		/*FHR*/
      ,p_hidden_flag		        =>  p_hidden_flag
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_cop_attribute_category         =>  p_cop_attribute_category
      ,p_cop_attribute1                 =>  p_cop_attribute1
      ,p_cop_attribute2                 =>  p_cop_attribute2
      ,p_cop_attribute3                 =>  p_cop_attribute3
      ,p_cop_attribute4                 =>  p_cop_attribute4
      ,p_cop_attribute5                 =>  p_cop_attribute5
      ,p_cop_attribute6                 =>  p_cop_attribute6
      ,p_cop_attribute7                 =>  p_cop_attribute7
      ,p_cop_attribute8                 =>  p_cop_attribute8
      ,p_cop_attribute9                 =>  p_cop_attribute9
      ,p_cop_attribute10                =>  p_cop_attribute10
      ,p_cop_attribute11                =>  p_cop_attribute11
      ,p_cop_attribute12                =>  p_cop_attribute12
      ,p_cop_attribute13                =>  p_cop_attribute13
      ,p_cop_attribute14                =>  p_cop_attribute14
      ,p_cop_attribute15                =>  p_cop_attribute15
      ,p_cop_attribute16                =>  p_cop_attribute16
      ,p_cop_attribute17                =>  p_cop_attribute17
      ,p_cop_attribute18                =>  p_cop_attribute18
      ,p_cop_attribute19                =>  p_cop_attribute19
      ,p_cop_attribute20                =>  p_cop_attribute20
      ,p_cop_attribute21                =>  p_cop_attribute21
      ,p_cop_attribute22                =>  p_cop_attribute22
      ,p_cop_attribute23                =>  p_cop_attribute23
      ,p_cop_attribute24                =>  p_cop_attribute24
      ,p_cop_attribute25                =>  p_cop_attribute25
      ,p_cop_attribute26                =>  p_cop_attribute26
      ,p_cop_attribute27                =>  p_cop_attribute27
      ,p_cop_attribute28                =>  p_cop_attribute28
      ,p_cop_attribute29                =>  p_cop_attribute29
      ,p_cop_attribute30                =>  p_cop_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Option_in_Plan'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_Option_in_Plan
    --
  end;
  --
  ben_cop_upd.upd
    (p_oipl_id                       => p_oipl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ivr_ident                     => p_ivr_ident
    ,p_url_ref_name                  => p_url_ref_name
    ,p_opt_id                        => p_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_rqd_perd_enrt_nenrt_val                      => p_rqd_perd_enrt_nenrt_val
    ,p_dflt_flag                     => p_dflt_flag
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_oipl_stat_cd                  => p_oipl_stat_cd
    ,p_pcp_dsgn_cd                   => p_pcp_dsgn_cd
    ,p_pcp_dpnt_dsgn_cd              => p_pcp_dpnt_dsgn_cd
    ,p_rqd_perd_enrt_nenrt_uom                  => p_rqd_perd_enrt_nenrt_uom
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_dflt_enrt_det_rl              => p_dflt_enrt_det_rl
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_mndtry_rl                     => p_mndtry_rl
    ,p_rqd_perd_enrt_nenrt_rl                     => p_rqd_perd_enrt_nenrt_rl
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_vrfy_fmly_mmbr_cd             => p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl             => p_vrfy_fmly_mmbr_rl
    ,p_enrt_cd                        =>  p_enrt_cd
    ,p_enrt_rl                        =>  p_enrt_rl
    ,p_auto_enrt_flag                => p_auto_enrt_flag
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_short_name  		     =>  p_short_name		/*FHR*/
    ,p_short_code		     =>  p_short_code		/*FHR*/
        ,p_legislation_code		     =>  p_legislation_code		/*FHR*/
        ,p_legislation_subgroup		     =>  p_legislation_subgroup		/*FHR*/
    ,p_hidden_flag		     =>  p_hidden_flag
    ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd         =>  p_ctfn_determine_cd
    ,p_cop_attribute_category        => p_cop_attribute_category
    ,p_cop_attribute1                => p_cop_attribute1
    ,p_cop_attribute2                => p_cop_attribute2
    ,p_cop_attribute3                => p_cop_attribute3
    ,p_cop_attribute4                => p_cop_attribute4
    ,p_cop_attribute5                => p_cop_attribute5
    ,p_cop_attribute6                => p_cop_attribute6
    ,p_cop_attribute7                => p_cop_attribute7
    ,p_cop_attribute8                => p_cop_attribute8
    ,p_cop_attribute9                => p_cop_attribute9
    ,p_cop_attribute10               => p_cop_attribute10
    ,p_cop_attribute11               => p_cop_attribute11
    ,p_cop_attribute12               => p_cop_attribute12
    ,p_cop_attribute13               => p_cop_attribute13
    ,p_cop_attribute14               => p_cop_attribute14
    ,p_cop_attribute15               => p_cop_attribute15
    ,p_cop_attribute16               => p_cop_attribute16
    ,p_cop_attribute17               => p_cop_attribute17
    ,p_cop_attribute18               => p_cop_attribute18
    ,p_cop_attribute19               => p_cop_attribute19
    ,p_cop_attribute20               => p_cop_attribute20
    ,p_cop_attribute21               => p_cop_attribute21
    ,p_cop_attribute22               => p_cop_attribute22
    ,p_cop_attribute23               => p_cop_attribute23
    ,p_cop_attribute24               => p_cop_attribute24
    ,p_cop_attribute25               => p_cop_attribute25
    ,p_cop_attribute26               => p_cop_attribute26
    ,p_cop_attribute27               => p_cop_attribute27
    ,p_cop_attribute28               => p_cop_attribute28
    ,p_cop_attribute29               => p_cop_attribute29
    ,p_cop_attribute30               => p_cop_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Option_in_Plan
    --
    ben_Option_in_Plan_bk2.update_Option_in_Plan_a
      (p_oipl_id                        =>  p_oipl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_opt_id                         =>  p_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_rqd_perd_enrt_nenrt_val                       =>  p_rqd_perd_enrt_nenrt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_oipl_stat_cd                   =>  p_oipl_stat_cd
      ,p_pcp_dsgn_cd                    =>  p_pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd               =>  p_pcp_dpnt_dsgn_cd
      ,p_rqd_perd_enrt_nenrt_uom                   =>  p_rqd_perd_enrt_nenrt_uom
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_mndtry_rl                      =>  p_mndtry_rl
      ,p_rqd_perd_enrt_nenrt_rl                      =>  p_rqd_perd_enrt_nenrt_rl
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_short_name  			=>  p_short_name		/*FHR*/
      ,p_short_code		        =>  p_short_code		/*FHR*/
            ,p_legislation_code		        =>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup		        =>  p_legislation_subgroup		/*FHR*/
      ,p_hidden_flag		        =>  p_hidden_flag
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd         =>  p_ctfn_determine_cd
      ,p_cop_attribute_category         =>  p_cop_attribute_category
      ,p_cop_attribute1                 =>  p_cop_attribute1
      ,p_cop_attribute2                 =>  p_cop_attribute2
      ,p_cop_attribute3                 =>  p_cop_attribute3
      ,p_cop_attribute4                 =>  p_cop_attribute4
      ,p_cop_attribute5                 =>  p_cop_attribute5
      ,p_cop_attribute6                 =>  p_cop_attribute6
      ,p_cop_attribute7                 =>  p_cop_attribute7
      ,p_cop_attribute8                 =>  p_cop_attribute8
      ,p_cop_attribute9                 =>  p_cop_attribute9
      ,p_cop_attribute10                =>  p_cop_attribute10
      ,p_cop_attribute11                =>  p_cop_attribute11
      ,p_cop_attribute12                =>  p_cop_attribute12
      ,p_cop_attribute13                =>  p_cop_attribute13
      ,p_cop_attribute14                =>  p_cop_attribute14
      ,p_cop_attribute15                =>  p_cop_attribute15
      ,p_cop_attribute16                =>  p_cop_attribute16
      ,p_cop_attribute17                =>  p_cop_attribute17
      ,p_cop_attribute18                =>  p_cop_attribute18
      ,p_cop_attribute19                =>  p_cop_attribute19
      ,p_cop_attribute20                =>  p_cop_attribute20
      ,p_cop_attribute21                =>  p_cop_attribute21
      ,p_cop_attribute22                =>  p_cop_attribute22
      ,p_cop_attribute23                =>  p_cop_attribute23
      ,p_cop_attribute24                =>  p_cop_attribute24
      ,p_cop_attribute25                =>  p_cop_attribute25
      ,p_cop_attribute26                =>  p_cop_attribute26
      ,p_cop_attribute27                =>  p_cop_attribute27
      ,p_cop_attribute28                =>  p_cop_attribute28
      ,p_cop_attribute29                =>  p_cop_attribute29
      ,p_cop_attribute30                =>  p_cop_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Option_in_Plan'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_Option_in_Plan
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
    ROLLBACK TO update_Option_in_Plan;
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
    ROLLBACK TO update_Option_in_Plan;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
  p_effective_end_date := null;

    raise;
    --
end update_Option_in_Plan;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Option_in_Plan >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Option_in_Plan
  (p_validate                       in  boolean  default false
  ,p_oipl_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  cursor c_opp is
     select opp.oiplip_id,
            opp.object_version_number
     from   ben_oiplip_f opp
     where  opp.oipl_id = p_oipl_id
     and    p_effective_date between
            opp.effective_start_date and opp.effective_end_date;
  -- To find the pgm, plan, opt and plan_typ for the oipl
  cursor c_exist_otp is
    select
      oipl.opt_id,
      plip.pgm_id,
      pl.pl_id,
      pl.pl_typ_id
    from
      ben_plip_f plip,
      ben_pl_f pl,
      ben_oipl_f oipl
    where
        oipl.oipl_id = p_oipl_id
    and oipl.pl_id = pl.pl_id
    and plip.pl_id = pl.pl_id
   -- and pl.business_group_id = p_business_group_id
   -- and plip.business_group_id = p_business_group_id
   -- and oipl.business_group_id = p_business_group_id
    and p_effective_date between  plip.effective_start_date and  plip.effective_end_date
    and p_effective_date between  oipl.effective_start_date and  oipl.effective_end_date
    and p_effective_date between   pl.effective_start_date and   pl.effective_end_date ;
  --
  cursor c_delete_otp(p_opt_id number ,
                      p_pgm_id number ,
                      p_pl_id  number,
                      p_pl_typ_id number ) is
    select
      otp.optip_id,
      otp.object_version_number
    from
      ben_optip_f otp
    where
        otp.pgm_id = p_pgm_id
    and otp.pl_typ_id = p_pl_typ_id
    and otp.opt_id = p_opt_id
 -- and otp.business_group_id = p_business_group_id
    and p_effective_date between otp.effective_start_date and otp.effective_end_date -- Bug 3023622
    and not exists ( select null
                     from
                       ben_plip_f plip,
                       ben_pl_f pl,
                       ben_oipl_f oipl
                     where -- plip.business_group_id = p_business_group_id
                         plip.pgm_id = p_pgm_id
                     and pl.pl_typ_id = p_pl_typ_id
                     and pl.pl_id = plip.pl_id
                     and pl.pl_id <> p_pl_id
                     and pl.pl_id = oipl.pl_id
                     and oipl.opt_id = p_opt_id
                     and p_effective_date
                         between  plip.effective_start_date and  plip.effective_end_date
                     and p_effective_date
                         between   pl.effective_start_date and   pl.effective_end_date
                     and p_effective_date
                         between oipl.effective_start_date and oipl.effective_end_date ) ;

  l_proc                  varchar2(72) := g_package||'update_Option_in_Plan';
  l_object_version_number ben_oipl_f.object_version_number%TYPE;
  l_effective_start_date  ben_oipl_f.effective_start_date%TYPE;
  l_effective_end_date    ben_oipl_f.effective_end_date%TYPE;
  --
  l_opp_effective_start_date  ben_oiplip_f.effective_start_date%type;
  l_opp_effective_end_date    ben_oiplip_f.effective_end_date%type;
  l_opp_object_version_number ben_oiplip_f.object_version_number%type;
  --
  l_otp_effective_start_date  ben_optip_f.effective_start_date%type;
  l_otp_effective_end_date    ben_optip_f.effective_end_date%type;
  l_otp_object_version_number ben_optip_f.object_version_number%type;
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Option_in_Plan;
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
    -- Start of API User Hook for the before hook of delete_Option_in_Plan
    --
    ben_Option_in_Plan_bk3.delete_Option_in_Plan_b
      (p_oipl_id                        =>  p_oipl_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Option_in_Plan'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_Option_in_Plan
    --
  end;
  --
 if p_datetrack_mode in ('ZAP') then
  -- bug 4339784, child records should not be checked for other delete datetrack modes
  -- Added above if condition to check for childs only for ZAP , DELETEs
  for l_opp in c_opp loop
    --
    l_opp_object_version_number := l_opp.object_version_number;
    --
    ben_option_in_plan_in_pgm_api.delete_option_in_plan_in_pgm(
        p_validate                => false,
        p_oiplip_id               => l_opp.oiplip_id,
        p_effective_start_date    => l_opp_effective_start_date,
        p_effective_end_date      => l_opp_effective_end_date,
        p_object_version_number   => l_opp_object_version_number,
        p_effective_date          => p_effective_date,
        p_datetrack_mode          => p_datetrack_mode
        );
    --
  end loop;
  --
  hr_utility.set_location('Before entering into Optip delete api ',24);
  for l_exist_otp  in c_exist_otp loop
    --
    hr_utility.set_location('Entering:'||l_proc||'in l_exist_otp ',25);
    for l_delete_otp in c_delete_otp(l_exist_otp.opt_id,
                                     l_exist_otp.pgm_id,
                                     l_exist_otp.pl_id,
                                     l_exist_otp.pl_typ_id ) loop
       --
       l_otp_object_version_number := l_delete_otp.object_version_number;
       --
       hr_utility.set_location('Entering:'||l_proc||'in l_delete_otp' ,26);
       hr_utility.set_location(' Opt_id '||l_exist_otp.opt_id , 26);
       hr_utility.set_location(' pgm_id '||l_exist_otp.pgm_id , 26);
       hr_utility.set_location(' pl_id  '||l_exist_otp.pl_id  , 26);
       hr_utility.set_location(' pl_typ_id '||l_exist_otp.pl_typ_id , 26);
       ben_opt_pltyp_in_pgm_api.delete_opt_pltyp_in_pgm(
        p_validate                => false,
        p_optip_id                => l_delete_otp.optip_id,
        p_effective_start_date    => l_otp_effective_start_date,
        p_effective_end_date      => l_otp_effective_end_date,
        p_object_version_number   => l_otp_object_version_number,
        p_effective_date          => p_effective_date,
        p_datetrack_mode          => p_datetrack_mode
        );
       --
    end loop;
    --
  end loop ;
 End if;
  hr_utility.set_location('After leaving Optip delete api ',27);
  --
  ben_cop_del.del
    (p_oipl_id                       => p_oipl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Option_in_Plan
    --
    ben_Option_in_Plan_bk3.delete_Option_in_Plan_a
      (p_oipl_id                        =>  p_oipl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Option_in_Plan'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_Option_in_Plan
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
    ROLLBACK TO delete_Option_in_Plan;
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
    ROLLBACK TO delete_Option_in_Plan;
    /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_Option_in_Plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_oipl_id                   in     number
  ,p_object_version_number     in     number
  ,p_effective_date            in     date
  ,p_datetrack_mode            in     varchar2
  ,p_validation_start_date     out nocopy    date
  ,p_validation_end_date       out nocopy    date) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_cop_shd.lck
    (p_oipl_id                 => p_oipl_id
    ,p_validation_start_date   => l_validation_start_date
    ,p_validation_end_date     => l_validation_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Option_in_Plan_api;

/
