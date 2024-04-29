--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_IN_PROGRAM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_IN_PROGRAM_API" as
/* $Header: becppapi.pkb 120.0 2005/05/28 01:16:26 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_in_Program_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_in_Program >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_in_Program
  (p_validate                       in  boolean   default false
  ,p_plip_id                        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default null
  ,p_plip_stat_cd                   in  varchar2  default null
  ,p_dflt_enrt_cd                   in  varchar2  default null
  ,p_dflt_enrt_det_rl               in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_enrt_rl                        in  number    default null
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default 'N'
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_postelcn_edit_rl               in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_short_name                    in  varchar2  default null
  ,p_short_code                    in  varchar2  default null
    ,p_legislation_code                    in  varchar2  default null
    ,p_legislation_subgroup                    in  varchar2  default null
  ,P_vrfy_fmly_mmbr_rl              in  number    default null
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,P_use_csd_rsd_prccng_cd          in  varchar2  default null
  ,p_cpp_attribute_category         in  varchar2  default null
  ,p_cpp_attribute1                 in  varchar2  default null
  ,p_cpp_attribute2                 in  varchar2  default null
  ,p_cpp_attribute3                 in  varchar2  default null
  ,p_cpp_attribute4                 in  varchar2  default null
  ,p_cpp_attribute5                 in  varchar2  default null
  ,p_cpp_attribute6                 in  varchar2  default null
  ,p_cpp_attribute7                 in  varchar2  default null
  ,p_cpp_attribute8                 in  varchar2  default null
  ,p_cpp_attribute9                 in  varchar2  default null
  ,p_cpp_attribute10                in  varchar2  default null
  ,p_cpp_attribute11                in  varchar2  default null
  ,p_cpp_attribute12                in  varchar2  default null
  ,p_cpp_attribute13                in  varchar2  default null
  ,p_cpp_attribute14                in  varchar2  default null
  ,p_cpp_attribute15                in  varchar2  default null
  ,p_cpp_attribute16                in  varchar2  default null
  ,p_cpp_attribute17                in  varchar2  default null
  ,p_cpp_attribute18                in  varchar2  default null
  ,p_cpp_attribute19                in  varchar2  default null
  ,p_cpp_attribute20                in  varchar2  default null
  ,p_cpp_attribute21                in  varchar2  default null
  ,p_cpp_attribute22                in  varchar2  default null
  ,p_cpp_attribute23                in  varchar2  default null
  ,p_cpp_attribute24                in  varchar2  default null
  ,p_cpp_attribute25                in  varchar2  default null
  ,p_cpp_attribute26                in  varchar2  default null
  ,p_cpp_attribute27                in  varchar2  default null
  ,p_cpp_attribute28                in  varchar2  default null
  ,p_cpp_attribute29                in  varchar2  default null
  ,p_cpp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_url_ref_name                   in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default null
  ,p_mn_cvg_amt                     in  number    default null
  ,p_mn_cvg_rl                      in  number    default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_cvg_incr_alwd_amt           in  number    default null
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default null
  ,p_mx_cvg_mlt_incr_num            in  number    default null
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default null
  ,p_mx_cvg_rl                      in  number    default null
  ,p_mx_cvg_wcfn_amt                in  number    default null
  ,p_mx_cvg_wcfn_mlt_num            in  number    default null
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_unsspnd_enrt_cd                in  varchar2  default null
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default null
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default null
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default null
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
 -- Declare cursors and local variables
  --
  cursor c_cop is
     select cop.oipl_id
     from   ben_oipl_f cop
     where  cop.pl_id = p_pl_id
     and    cop.business_group_id + 0 = p_business_group_id
     and    p_effective_date between
            cop.effective_start_date and cop.effective_end_date;
  --
  cursor c_otp is
    select
      plip.pgm_id,
      pl.pl_typ_id,
      ptip.ptip_id,
      oipl.opt_id
    from
      ben_oipl_f oipl,
      ben_ptip_f ptip,
      ben_plip_f plip,
      ben_pl_f pl
    where
        pl.pl_id = p_pl_id
    and plip.pl_id = pl.pl_id
    and ptip.pgm_id = p_pgm_id
    and pl.business_group_id = p_business_group_id
    and plip.business_group_id = p_business_group_id
    and oipl.business_group_id = p_business_group_id
    and plip.pgm_id = ptip.pgm_id
    and pl.pl_typ_id = ptip.pl_typ_id
    and pl.pl_id = oipl.pl_id
    and p_effective_date between  plip.effective_start_date and  plip.effective_end_date
    and p_effective_date between   pl.effective_start_date and   pl.effective_end_date
    and p_effective_date between ptip.effective_start_date and ptip.effective_end_date
    and p_effective_date between oipl.effective_start_date and oipl.effective_end_date ;


  l_plip_id ben_plip_f.plip_id%TYPE;
  l_effective_start_date ben_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_plip_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan_in_Program';
  l_object_version_number ben_plip_f.object_version_number%TYPE;
  --
  l_oiplip_id                 ben_oiplip_f.oiplip_id%type;
  l_opp_effective_start_date  ben_oiplip_f.effective_start_date%type;
  l_opp_effective_end_date    ben_oiplip_f.effective_end_date%type;
  l_opp_object_version_number ben_oiplip_f.object_version_number%type;
  --
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
  savepoint create_Plan_in_Program;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan_in_Program
    --
    ben_Plan_in_Program_bk1.create_Plan_in_Program_b
      (
       p_dflt_flag                      =>  p_dflt_flag
      ,p_plip_stat_cd                   =>  p_plip_stat_cd
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_ordr_num                       =>  p_ordr_num
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_short_name                    =>  p_short_name
      ,p_short_code                    =>  p_short_code
            ,p_legislation_code                    =>  p_legislation_code
            ,p_legislation_subgroup                    =>  p_legislation_subgroup
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,P_use_csd_rsd_prccng_cd          =>  P_use_csd_rsd_prccng_cd
      ,p_cpp_attribute_category         =>  p_cpp_attribute_category
      ,p_cpp_attribute1                 =>  p_cpp_attribute1
      ,p_cpp_attribute2                 =>  p_cpp_attribute2
      ,p_cpp_attribute3                 =>  p_cpp_attribute3
      ,p_cpp_attribute4                 =>  p_cpp_attribute4
      ,p_cpp_attribute5                 =>  p_cpp_attribute5
      ,p_cpp_attribute6                 =>  p_cpp_attribute6
      ,p_cpp_attribute7                 =>  p_cpp_attribute7
      ,p_cpp_attribute8                 =>  p_cpp_attribute8
      ,p_cpp_attribute9                 =>  p_cpp_attribute9
      ,p_cpp_attribute10                =>  p_cpp_attribute10
      ,p_cpp_attribute11                =>  p_cpp_attribute11
      ,p_cpp_attribute12                =>  p_cpp_attribute12
      ,p_cpp_attribute13                =>  p_cpp_attribute13
      ,p_cpp_attribute14                =>  p_cpp_attribute14
      ,p_cpp_attribute15                =>  p_cpp_attribute15
      ,p_cpp_attribute16                =>  p_cpp_attribute16
      ,p_cpp_attribute17                =>  p_cpp_attribute17
      ,p_cpp_attribute18                =>  p_cpp_attribute18
      ,p_cpp_attribute19                =>  p_cpp_attribute19
      ,p_cpp_attribute20                =>  p_cpp_attribute20
      ,p_cpp_attribute21                =>  p_cpp_attribute21
      ,p_cpp_attribute22                =>  p_cpp_attribute22
      ,p_cpp_attribute23                =>  p_cpp_attribute23
      ,p_cpp_attribute24                =>  p_cpp_attribute24
      ,p_cpp_attribute25                =>  p_cpp_attribute25
      ,p_cpp_attribute26                =>  p_cpp_attribute26
      ,p_cpp_attribute27                =>  p_cpp_attribute27
      ,p_cpp_attribute28                =>  p_cpp_attribute28
      ,p_cpp_attribute29                =>  p_cpp_attribute29
      ,p_cpp_attribute30                =>  p_cpp_attribute30
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan_in_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan_in_Program
    --
  end;
  --
  BEN_CPP_ins.ins
    (
     p_plip_id                       => l_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dflt_flag                     => p_dflt_flag
    ,p_plip_stat_cd                  => p_plip_stat_cd
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_det_rl              => p_dflt_enrt_det_rl
    ,p_ordr_num                      => p_ordr_num
    ,p_ivr_ident                     => p_ivr_ident
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_enrt_rl                       => p_enrt_rl
    ,p_alws_unrstrctd_enrt_flag      => p_alws_unrstrctd_enrt_flag
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_short_name                   => p_short_name
    ,p_short_code                   => p_short_code
        ,p_legislation_code                   => p_legislation_code
        ,p_legislation_subgroup                   => p_legislation_subgroup
    ,P_vrfy_fmly_mmbr_rl             => P_vrfy_fmly_mmbr_rl
    ,P_vrfy_fmly_mmbr_cd             => P_vrfy_fmly_mmbr_cd
    ,P_use_csd_rsd_prccng_cd         => P_use_csd_rsd_prccng_cd
    ,p_cpp_attribute_category        => p_cpp_attribute_category
    ,p_cpp_attribute1                => p_cpp_attribute1
    ,p_cpp_attribute2                => p_cpp_attribute2
    ,p_cpp_attribute3                => p_cpp_attribute3
    ,p_cpp_attribute4                => p_cpp_attribute4
    ,p_cpp_attribute5                => p_cpp_attribute5
    ,p_cpp_attribute6                => p_cpp_attribute6
    ,p_cpp_attribute7                => p_cpp_attribute7
    ,p_cpp_attribute8                => p_cpp_attribute8
    ,p_cpp_attribute9                => p_cpp_attribute9
    ,p_cpp_attribute10               => p_cpp_attribute10
    ,p_cpp_attribute11               => p_cpp_attribute11
    ,p_cpp_attribute12               => p_cpp_attribute12
    ,p_cpp_attribute13               => p_cpp_attribute13
    ,p_cpp_attribute14               => p_cpp_attribute14
    ,p_cpp_attribute15               => p_cpp_attribute15
    ,p_cpp_attribute16               => p_cpp_attribute16
    ,p_cpp_attribute17               => p_cpp_attribute17
    ,p_cpp_attribute18               => p_cpp_attribute18
    ,p_cpp_attribute19               => p_cpp_attribute19
    ,p_cpp_attribute20               => p_cpp_attribute20
    ,p_cpp_attribute21               => p_cpp_attribute21
    ,p_cpp_attribute22               => p_cpp_attribute22
    ,p_cpp_attribute23               => p_cpp_attribute23
    ,p_cpp_attribute24               => p_cpp_attribute24
    ,p_cpp_attribute25               => p_cpp_attribute25
    ,p_cpp_attribute26               => p_cpp_attribute26
    ,p_cpp_attribute27               => p_cpp_attribute27
    ,p_cpp_attribute28               => p_cpp_attribute28
    ,p_cpp_attribute29               => p_cpp_attribute29
    ,p_cpp_attribute30               => p_cpp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_url_ref_name                  => p_url_ref_name
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_mn_cvg_amt                    => p_mn_cvg_amt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_no_mn_cvg_amt_apls_flag       => p_no_mn_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_prort_prtl_yr_cvg_rstrn_cd    => p_prort_prtl_yr_cvg_rstrn_cd
    ,p_prort_prtl_yr_cvg_rstrn_rl    => p_prort_prtl_yr_cvg_rstrn_rl
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_bnft_or_option_rstrctn_cd     => p_bnft_or_option_rstrctn_cd
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan_in_Program
    --
    ben_Plan_in_Program_bk1.create_Plan_in_Program_a
      (
       p_plip_id                        =>  l_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_plip_stat_cd                   =>  p_plip_stat_cd
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_ordr_num                       =>  p_ordr_num
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_short_name                    =>  p_short_name
      ,p_short_code                    =>  p_short_code
            ,p_legislation_code                    =>  p_legislation_code
            ,p_legislation_subgroup                    =>  p_legislation_subgroup
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,P_use_csd_rsd_prccng_cd          =>  P_use_csd_rsd_prccng_cd
      ,p_cpp_attribute_category         =>  p_cpp_attribute_category
      ,p_cpp_attribute1                 =>  p_cpp_attribute1
      ,p_cpp_attribute2                 =>  p_cpp_attribute2
      ,p_cpp_attribute3                 =>  p_cpp_attribute3
      ,p_cpp_attribute4                 =>  p_cpp_attribute4
      ,p_cpp_attribute5                 =>  p_cpp_attribute5
      ,p_cpp_attribute6                 =>  p_cpp_attribute6
      ,p_cpp_attribute7                 =>  p_cpp_attribute7
      ,p_cpp_attribute8                 =>  p_cpp_attribute8
      ,p_cpp_attribute9                 =>  p_cpp_attribute9
      ,p_cpp_attribute10                =>  p_cpp_attribute10
      ,p_cpp_attribute11                =>  p_cpp_attribute11
      ,p_cpp_attribute12                =>  p_cpp_attribute12
      ,p_cpp_attribute13                =>  p_cpp_attribute13
      ,p_cpp_attribute14                =>  p_cpp_attribute14
      ,p_cpp_attribute15                =>  p_cpp_attribute15
      ,p_cpp_attribute16                =>  p_cpp_attribute16
      ,p_cpp_attribute17                =>  p_cpp_attribute17
      ,p_cpp_attribute18                =>  p_cpp_attribute18
      ,p_cpp_attribute19                =>  p_cpp_attribute19
      ,p_cpp_attribute20                =>  p_cpp_attribute20
      ,p_cpp_attribute21                =>  p_cpp_attribute21
      ,p_cpp_attribute22                =>  p_cpp_attribute22
      ,p_cpp_attribute23                =>  p_cpp_attribute23
      ,p_cpp_attribute24                =>  p_cpp_attribute24
      ,p_cpp_attribute25                =>  p_cpp_attribute25
      ,p_cpp_attribute26                =>  p_cpp_attribute26
      ,p_cpp_attribute27                =>  p_cpp_attribute27
      ,p_cpp_attribute28                =>  p_cpp_attribute28
      ,p_cpp_attribute29                =>  p_cpp_attribute29
      ,p_cpp_attribute30                =>  p_cpp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan_in_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan_in_Program
    --
  end;
  --
 for l_cop in c_cop loop
    --
    ben_option_in_plan_in_pgm_api.create_option_in_plan_in_pgm(
         p_validate                => false,
         p_oiplip_id               => l_oiplip_id,
         p_effective_start_date    => l_opp_effective_start_date,
         p_effective_end_date      => l_opp_effective_end_date,
         p_oipl_id                 => l_cop.oipl_id,
         p_plip_id                 => l_plip_id,
         p_business_group_id       => p_business_group_id,
         p_object_version_number   => l_opp_object_version_number,
         p_effective_date          => p_effective_date);
    --
  end loop;
  -- bug 1285336
  hr_utility.set_location(l_proc, 60);
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
        ,p_opt_id                        =>l_otp.opt_id
    --  ,p_cmbn_ptip_opt_id              =>p_cmbn_ptip_opt_id
        ,p_object_version_number         =>l_otp_object_version_number
        ,p_effective_date                =>p_effective_date
    );
    hr_utility.set_location('Before entering into create_opt_pltyp_in_pgm ', 66);
  END LOOP ;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_plip_id := l_plip_id;
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
    ROLLBACK TO create_Plan_in_Program;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_plip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Plan_in_Program;
    raise;
    --
end create_Plan_in_Program;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_in_Program >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_in_Program
  (p_validate                       in  boolean   default false
  ,p_plip_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_plip_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_det_rl               in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_short_name                    in  varchar2  default hr_api.g_varchar2
  ,p_short_code                    in  varchar2  default hr_api.g_varchar2
    ,p_legislation_code                    in  varchar2  default hr_api.g_varchar2
    ,p_legislation_subgroup                    in  varchar2  default hr_api.g_varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,P_use_csd_rsd_prccng_cd          in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default hr_api.g_number
  ,p_mn_cvg_amt                     in  number    default hr_api.g_number
  ,p_mn_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_incr_alwd_amt           in  number    default hr_api.g_number
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_num            in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default hr_api.g_number
  ,p_mx_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_mlt_num            in  number    default hr_api.g_number
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_unsspnd_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default hr_api.g_varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default hr_api.g_number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default hr_api.g_varchar2
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_in_Program';
  l_object_version_number ben_plip_f.object_version_number%TYPE;
  l_effective_start_date ben_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_plip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Plan_in_Program;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan_in_Program
    --
    ben_Plan_in_Program_bk2.update_Plan_in_Program_b
      (
       p_plip_id                        =>  p_plip_id
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_plip_stat_cd                   =>  p_plip_stat_cd
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_ordr_num                       =>  p_ordr_num
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_short_name                    =>  p_short_name
      ,p_short_code                    =>  p_short_code
            ,p_legislation_code                    =>  p_legislation_code
            ,p_legislation_subgroup                    =>  p_legislation_subgroup
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,P_use_csd_rsd_prccng_cd          =>  P_use_csd_rsd_prccng_cd
      ,p_cpp_attribute_category         =>  p_cpp_attribute_category
      ,p_cpp_attribute1                 =>  p_cpp_attribute1
      ,p_cpp_attribute2                 =>  p_cpp_attribute2
      ,p_cpp_attribute3                 =>  p_cpp_attribute3
      ,p_cpp_attribute4                 =>  p_cpp_attribute4
      ,p_cpp_attribute5                 =>  p_cpp_attribute5
      ,p_cpp_attribute6                 =>  p_cpp_attribute6
      ,p_cpp_attribute7                 =>  p_cpp_attribute7
      ,p_cpp_attribute8                 =>  p_cpp_attribute8
      ,p_cpp_attribute9                 =>  p_cpp_attribute9
      ,p_cpp_attribute10                =>  p_cpp_attribute10
      ,p_cpp_attribute11                =>  p_cpp_attribute11
      ,p_cpp_attribute12                =>  p_cpp_attribute12
      ,p_cpp_attribute13                =>  p_cpp_attribute13
      ,p_cpp_attribute14                =>  p_cpp_attribute14
      ,p_cpp_attribute15                =>  p_cpp_attribute15
      ,p_cpp_attribute16                =>  p_cpp_attribute16
      ,p_cpp_attribute17                =>  p_cpp_attribute17
      ,p_cpp_attribute18                =>  p_cpp_attribute18
      ,p_cpp_attribute19                =>  p_cpp_attribute19
      ,p_cpp_attribute20                =>  p_cpp_attribute20
      ,p_cpp_attribute21                =>  p_cpp_attribute21
      ,p_cpp_attribute22                =>  p_cpp_attribute22
      ,p_cpp_attribute23                =>  p_cpp_attribute23
      ,p_cpp_attribute24                =>  p_cpp_attribute24
      ,p_cpp_attribute25                =>  p_cpp_attribute25
      ,p_cpp_attribute26                =>  p_cpp_attribute26
      ,p_cpp_attribute27                =>  p_cpp_attribute27
      ,p_cpp_attribute28                =>  p_cpp_attribute28
      ,p_cpp_attribute29                =>  p_cpp_attribute29
      ,p_cpp_attribute30                =>  p_cpp_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_in_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan_in_Program
    --
  end;
  --
  BEN_CPP_upd.upd
    (
     p_plip_id                       => p_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dflt_flag                     => p_dflt_flag
    ,p_plip_stat_cd                  => p_plip_stat_cd
    ,p_dflt_enrt_cd                  => p_dflt_enrt_cd
    ,p_dflt_enrt_det_rl              => p_dflt_enrt_det_rl
    ,p_ordr_num                      => p_ordr_num
    ,p_ivr_ident                     => p_ivr_ident
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_enrt_rl                       => p_enrt_rl
    ,p_alws_unrstrctd_enrt_flag      => p_alws_unrstrctd_enrt_flag
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_short_name                   => p_short_name
    ,p_short_code                   => p_short_code
        ,p_legislation_code                   => p_legislation_code
        ,p_legislation_subgroup                   => p_legislation_subgroup
    ,P_vrfy_fmly_mmbr_rl             => P_vrfy_fmly_mmbr_rl
    ,P_vrfy_fmly_mmbr_cd             => P_vrfy_fmly_mmbr_cd
    ,P_use_csd_rsd_prccng_cd         => P_use_csd_rsd_prccng_cd
    ,p_cpp_attribute_category        => p_cpp_attribute_category
    ,p_cpp_attribute1                => p_cpp_attribute1
    ,p_cpp_attribute2                => p_cpp_attribute2
    ,p_cpp_attribute3                => p_cpp_attribute3
    ,p_cpp_attribute4                => p_cpp_attribute4
    ,p_cpp_attribute5                => p_cpp_attribute5
    ,p_cpp_attribute6                => p_cpp_attribute6
    ,p_cpp_attribute7                => p_cpp_attribute7
    ,p_cpp_attribute8                => p_cpp_attribute8
    ,p_cpp_attribute9                => p_cpp_attribute9
    ,p_cpp_attribute10               => p_cpp_attribute10
    ,p_cpp_attribute11               => p_cpp_attribute11
    ,p_cpp_attribute12               => p_cpp_attribute12
    ,p_cpp_attribute13               => p_cpp_attribute13
    ,p_cpp_attribute14               => p_cpp_attribute14
    ,p_cpp_attribute15               => p_cpp_attribute15
    ,p_cpp_attribute16               => p_cpp_attribute16
    ,p_cpp_attribute17               => p_cpp_attribute17
    ,p_cpp_attribute18               => p_cpp_attribute18
    ,p_cpp_attribute19               => p_cpp_attribute19
    ,p_cpp_attribute20               => p_cpp_attribute20
    ,p_cpp_attribute21               => p_cpp_attribute21
    ,p_cpp_attribute22               => p_cpp_attribute22
    ,p_cpp_attribute23               => p_cpp_attribute23
    ,p_cpp_attribute24               => p_cpp_attribute24
    ,p_cpp_attribute25               => p_cpp_attribute25
    ,p_cpp_attribute26               => p_cpp_attribute26
    ,p_cpp_attribute27               => p_cpp_attribute27
    ,p_cpp_attribute28               => p_cpp_attribute28
    ,p_cpp_attribute29               => p_cpp_attribute29
    ,p_cpp_attribute30               => p_cpp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_url_ref_name                  => p_url_ref_name
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_mn_cvg_amt                    => p_mn_cvg_amt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_no_mn_cvg_amt_apls_flag       => p_no_mn_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_prort_prtl_yr_cvg_rstrn_cd    => p_prort_prtl_yr_cvg_rstrn_cd
    ,p_prort_prtl_yr_cvg_rstrn_rl    => p_prort_prtl_yr_cvg_rstrn_rl
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_bnft_or_option_rstrctn_cd     => p_bnft_or_option_rstrctn_cd
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan_in_Program
    --
    ben_Plan_in_Program_bk2.update_Plan_in_Program_a
      (
       p_plip_id                        =>  p_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_plip_stat_cd                   =>  p_plip_stat_cd
      ,p_dflt_enrt_cd                   =>  p_dflt_enrt_cd
      ,p_dflt_enrt_det_rl               =>  p_dflt_enrt_det_rl
      ,p_ordr_num                       =>  p_ordr_num
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_short_name                    =>  p_short_name
      ,p_short_code                    =>  p_short_code
            ,p_legislation_code                    =>  p_legislation_code
            ,p_legislation_subgroup                    =>  p_legislation_subgroup
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,P_use_csd_rsd_prccng_cd          =>  P_use_csd_rsd_prccng_cd
      ,p_cpp_attribute_category         =>  p_cpp_attribute_category
      ,p_cpp_attribute1                 =>  p_cpp_attribute1
      ,p_cpp_attribute2                 =>  p_cpp_attribute2
      ,p_cpp_attribute3                 =>  p_cpp_attribute3
      ,p_cpp_attribute4                 =>  p_cpp_attribute4
      ,p_cpp_attribute5                 =>  p_cpp_attribute5
      ,p_cpp_attribute6                 =>  p_cpp_attribute6
      ,p_cpp_attribute7                 =>  p_cpp_attribute7
      ,p_cpp_attribute8                 =>  p_cpp_attribute8
      ,p_cpp_attribute9                 =>  p_cpp_attribute9
      ,p_cpp_attribute10                =>  p_cpp_attribute10
      ,p_cpp_attribute11                =>  p_cpp_attribute11
      ,p_cpp_attribute12                =>  p_cpp_attribute12
      ,p_cpp_attribute13                =>  p_cpp_attribute13
      ,p_cpp_attribute14                =>  p_cpp_attribute14
      ,p_cpp_attribute15                =>  p_cpp_attribute15
      ,p_cpp_attribute16                =>  p_cpp_attribute16
      ,p_cpp_attribute17                =>  p_cpp_attribute17
      ,p_cpp_attribute18                =>  p_cpp_attribute18
      ,p_cpp_attribute19                =>  p_cpp_attribute19
      ,p_cpp_attribute20                =>  p_cpp_attribute20
      ,p_cpp_attribute21                =>  p_cpp_attribute21
      ,p_cpp_attribute22                =>  p_cpp_attribute22
      ,p_cpp_attribute23                =>  p_cpp_attribute23
      ,p_cpp_attribute24                =>  p_cpp_attribute24
      ,p_cpp_attribute25                =>  p_cpp_attribute25
      ,p_cpp_attribute26                =>  p_cpp_attribute26
      ,p_cpp_attribute27                =>  p_cpp_attribute27
      ,p_cpp_attribute28                =>  p_cpp_attribute28
      ,p_cpp_attribute29                =>  p_cpp_attribute29
      ,p_cpp_attribute30                =>  p_cpp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_mn_cvg_amt                     =>  p_mn_cvg_amt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_in_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan_in_Program
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
    ROLLBACK TO update_Plan_in_Program;
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
    ROLLBACK TO update_Plan_in_Program;
    raise;
    --
end update_Plan_in_Program;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_in_Program >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_in_Program
  (p_validate                       in  boolean  default false
  ,p_plip_id                        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

     cursor c_opp is select opp.oiplip_id,
            opp.object_version_number
     from   ben_oiplip_f opp
     where  opp.plip_id = p_plip_id
     and    p_effective_date between
            opp.effective_start_date and opp.effective_end_date;
  --
  l_proc varchar2(72) := g_package||'update_Plan_in_Program';
  l_object_version_number ben_plip_f.object_version_number%TYPE;
  l_effective_start_date ben_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_plip_f.effective_end_date%TYPE;
  --
  l_opp_effective_start_date  ben_oiplip_f.effective_start_date%type;
  l_opp_effective_end_date    ben_oiplip_f.effective_end_date%type;
  l_opp_object_version_number ben_oiplip_f.object_version_number%type;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Plan_in_Program;
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
    -- Start of API User Hook for the before hook of delete_Plan_in_Program
    --
    ben_Plan_in_Program_bk3.delete_Plan_in_Program_b
      (
       p_plip_id                        =>  p_plip_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_in_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan_in_Program
    --
  end;
  --
  BEN_CPP_del.del
    (
     p_plip_id                       => p_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan_in_Program
    --
    ben_Plan_in_Program_bk3.delete_Plan_in_Program_a
      (
       p_plip_id                        =>  p_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_in_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan_in_Program
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
    ROLLBACK TO delete_Plan_in_Program;
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
    ROLLBACK TO delete_Plan_in_Program;
    raise;
    --
end delete_Plan_in_Program;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_plip_id                   in     number
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
  BEN_CPP_shd.lck
    (
      p_plip_id                 => p_plip_id
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
end ben_Plan_in_Program_api;

/
