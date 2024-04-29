--------------------------------------------------------
--  DDL for Package Body BEN_PROGRAM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROGRAM_API" as
/* $Header: bepgmapi.pkb 120.0 2005/05/28 10:46:40 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Program_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Program >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Program
  (p_validate                       in  boolean   default false
  ,p_pgm_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default null
  ,p_pgm_prvds_no_auto_enrt_flag    in  varchar2  default null
  ,p_dpnt_dob_rqd_flag              in  varchar2  default null
  ,p_pgm_prvds_no_dflt_enrt_flag    in  varchar2  default null
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default null
  ,p_dpnt_dsgn_lvl_cd               in  varchar2  default null
  ,p_pgm_stat_cd                    in  varchar2  default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_uses_all_asmts_for_rts_flag    in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_pgm_desc                       in  varchar2  default null
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default null
  ,p_pgm_use_all_asnts_elig_flag    in  varchar2  default null
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_mx_dpnt_pct_prtt_lf_amt        in  number    default null
  ,p_mx_sps_pct_prtt_lf_amt         in  number    default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_coord_cvg_for_all_pls_flg      in  varchar2  default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default null
  ,p_dpnt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  number    default null
  ,p_dpnt_dsgn_no_ctfn_rqd_flag     in  varchar2  default null
  ,p_drvbl_fctr_dpnt_elig_flag      in  varchar2  default null
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_info_rt_freq_cd           in  varchar2  default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_pgm_grp_cd                     in  varchar2  default null
  ,p_pgm_uom                        in  varchar2  default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default null
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_poe_lvl_cd                     in  varchar2  default null
  ,p_enrt_rl                        in  number    default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_trk_inelig_per_flag            in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,P_vrfy_fmly_mmbr_rl              in  number    default null
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,P_short_name                     in  varchar2  default null        /*FHR*/
  ,p_short_code		     	    in  varchar2  default null        /*FHR*/
    ,p_legislation_code		     	    in  varchar2  default null        /*FHR*/
    ,p_legislation_subgroup		     	    in  varchar2  default null        /*FHR*/
  ,p_Dflt_pgm_flag                  in  Varchar2  default null
  ,p_Use_prog_points_flag           in  Varchar2  default null
  ,p_Dflt_step_cd                   in  Varchar2  default null
  ,p_Dflt_step_rl                   in  number    default null
  ,p_Update_salary_cd               in  Varchar2  default null
  ,p_Use_multi_pay_rates_flag       in  Varchar2  default null
  ,p_dflt_element_type_id           in  number    default null
  ,p_Dflt_input_value_id            in  number    default null
  ,p_Use_scores_cd                  in  Varchar2  default null
  ,p_Scores_calc_mthd_cd            in  Varchar2  default null
  ,p_Scores_calc_rl                 in  number    default null
  ,p_gsp_allow_override_flag         in  varchar2  default null
  ,p_use_variable_rates_flag         in  varchar2  default null
  ,p_salary_calc_mthd_cd         in  varchar2  default null
  ,p_salary_calc_mthd_rl         in  number  default null
  ,p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2  default null
  ,p_susp_if_ctfn_not_dpnt_flag    in  varchar2  default 'Y'
  ,p_dpnt_ctfn_determine_cd        in  varchar2  default null
  ,p_pgm_attribute_category         in  varchar2  default null
  ,p_pgm_attribute1                 in  varchar2  default null
  ,p_pgm_attribute2                 in  varchar2  default null
  ,p_pgm_attribute3                 in  varchar2  default null
  ,p_pgm_attribute4                 in  varchar2  default null
  ,p_pgm_attribute5                 in  varchar2  default null
  ,p_pgm_attribute6                 in  varchar2  default null
  ,p_pgm_attribute7                 in  varchar2  default null
  ,p_pgm_attribute8                 in  varchar2  default null
  ,p_pgm_attribute9                 in  varchar2  default null
  ,p_pgm_attribute10                in  varchar2  default null
  ,p_pgm_attribute11                in  varchar2  default null
  ,p_pgm_attribute12                in  varchar2  default null
  ,p_pgm_attribute13                in  varchar2  default null
  ,p_pgm_attribute14                in  varchar2  default null
  ,p_pgm_attribute15                in  varchar2  default null
  ,p_pgm_attribute16                in  varchar2  default null
  ,p_pgm_attribute17                in  varchar2  default null
  ,p_pgm_attribute18                in  varchar2  default null
  ,p_pgm_attribute19                in  varchar2  default null
  ,p_pgm_attribute20                in  varchar2  default null
  ,p_pgm_attribute21                in  varchar2  default null
  ,p_pgm_attribute22                in  varchar2  default null
  ,p_pgm_attribute23                in  varchar2  default null
  ,p_pgm_attribute24                in  varchar2  default null
  ,p_pgm_attribute25                in  varchar2  default null
  ,p_pgm_attribute26                in  varchar2  default null
  ,p_pgm_attribute27                in  varchar2  default null
  ,p_pgm_attribute28                in  varchar2  default null
  ,p_pgm_attribute29                in  varchar2  default null
  ,p_pgm_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pgm_id ben_pgm_f.pgm_id%TYPE;
  l_effective_start_date ben_pgm_f.effective_start_date%TYPE;
  l_effective_end_date ben_pgm_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Program';
  l_object_version_number ben_pgm_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Program;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Program
    --
    ben_Program_bk1.create_Program_b
      (
       p_name                           =>  p_name
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_pgm_prvds_no_auto_enrt_flag    =>  p_pgm_prvds_no_auto_enrt_flag
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_pgm_prvds_no_dflt_enrt_flag    =>  p_pgm_prvds_no_dflt_enrt_flag
      ,p_dpnt_legv_id_rqd_flag          =>  p_dpnt_legv_id_rqd_flag
      ,p_dpnt_dsgn_lvl_cd               =>  p_dpnt_dsgn_lvl_cd
      ,p_pgm_stat_cd                    =>  p_pgm_stat_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_pgm_typ_cd                     =>  p_pgm_typ_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_uses_all_asmts_for_rts_flag    =>  p_uses_all_asmts_for_rts_flag
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_pgm_desc                       =>  p_pgm_desc
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_pgm_use_all_asnts_elig_flag    =>  p_pgm_use_all_asnts_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_mx_dpnt_pct_prtt_lf_amt        =>  p_mx_dpnt_pct_prtt_lf_amt
      ,p_mx_sps_pct_prtt_lf_amt         =>  p_mx_sps_pct_prtt_lf_amt
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_coord_cvg_for_all_pls_flg      =>  p_coord_cvg_for_all_pls_flg
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dsgn_no_ctfn_rqd_flag     =>  p_dpnt_dsgn_no_ctfn_rqd_flag
      ,p_drvbl_fctr_dpnt_elig_flag      =>  p_drvbl_fctr_dpnt_elig_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_info_rt_freq_cd           =>  p_enrt_info_rt_freq_cd
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_pgm_grp_cd                     =>  p_pgm_grp_cd
      ,p_pgm_uom                        =>  p_pgm_uom
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_poe_lvl_cd                     =>  p_poe_lvl_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,p_short_name			=>  p_short_name		/*FHR*/
      ,p_short_code			=>  p_short_code		/*FHR*/
            ,p_legislation_code			=>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup			=>  p_legislation_subgroup		/*FHR*/
      ,p_Dflt_pgm_flag                  =>  p_Dflt_pgm_flag
      ,p_Use_prog_points_flag           =>  p_Use_prog_points_flag
      ,p_Dflt_step_cd                   =>  p_Dflt_step_cd
      ,p_Dflt_step_rl                   =>  p_Dflt_step_rl
      ,p_Update_salary_cd               =>  p_Update_salary_cd
      ,p_Use_multi_pay_rates_flag        =>  p_Use_multi_pay_rates_flag
      ,p_dflt_element_type_id           =>  p_dflt_element_type_id
      ,p_Dflt_input_value_id            =>  p_Dflt_input_value_id
      ,p_Use_scores_cd                  =>  p_Use_scores_cd
      ,p_Scores_calc_mthd_cd            =>  p_Scores_calc_mthd_cd
      ,p_Scores_calc_rl                 =>  p_Scores_calc_rl
      ,p_gsp_allow_override_flag         =>  p_gsp_allow_override_flag
      ,p_use_variable_rates_flag         =>  p_use_variable_rates_flag
      ,p_salary_calc_mthd_cd         =>  p_salary_calc_mthd_cd
      ,p_salary_calc_mthd_rl         =>  p_salary_calc_mthd_rl
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_pgm_attribute_category         =>  p_pgm_attribute_category
      ,p_pgm_attribute1                 =>  p_pgm_attribute1
      ,p_pgm_attribute2                 =>  p_pgm_attribute2
      ,p_pgm_attribute3                 =>  p_pgm_attribute3
      ,p_pgm_attribute4                 =>  p_pgm_attribute4
      ,p_pgm_attribute5                 =>  p_pgm_attribute5
      ,p_pgm_attribute6                 =>  p_pgm_attribute6
      ,p_pgm_attribute7                 =>  p_pgm_attribute7
      ,p_pgm_attribute8                 =>  p_pgm_attribute8
      ,p_pgm_attribute9                 =>  p_pgm_attribute9
      ,p_pgm_attribute10                =>  p_pgm_attribute10
      ,p_pgm_attribute11                =>  p_pgm_attribute11
      ,p_pgm_attribute12                =>  p_pgm_attribute12
      ,p_pgm_attribute13                =>  p_pgm_attribute13
      ,p_pgm_attribute14                =>  p_pgm_attribute14
      ,p_pgm_attribute15                =>  p_pgm_attribute15
      ,p_pgm_attribute16                =>  p_pgm_attribute16
      ,p_pgm_attribute17                =>  p_pgm_attribute17
      ,p_pgm_attribute18                =>  p_pgm_attribute18
      ,p_pgm_attribute19                =>  p_pgm_attribute19
      ,p_pgm_attribute20                =>  p_pgm_attribute20
      ,p_pgm_attribute21                =>  p_pgm_attribute21
      ,p_pgm_attribute22                =>  p_pgm_attribute22
      ,p_pgm_attribute23                =>  p_pgm_attribute23
      ,p_pgm_attribute24                =>  p_pgm_attribute24
      ,p_pgm_attribute25                =>  p_pgm_attribute25
      ,p_pgm_attribute26                =>  p_pgm_attribute26
      ,p_pgm_attribute27                =>  p_pgm_attribute27
      ,p_pgm_attribute28                =>  p_pgm_attribute28
      ,p_pgm_attribute29                =>  p_pgm_attribute29
      ,p_pgm_attribute30                =>  p_pgm_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Program
    --
  end;
  --
  ben_pgm_ins.ins
    (
     p_pgm_id                        => l_pgm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_dpnt_adrs_rqd_flag            => p_dpnt_adrs_rqd_flag
    ,p_pgm_prvds_no_auto_enrt_flag   => p_pgm_prvds_no_auto_enrt_flag
    ,p_dpnt_dob_rqd_flag             => p_dpnt_dob_rqd_flag
    ,p_pgm_prvds_no_dflt_enrt_flag   => p_pgm_prvds_no_dflt_enrt_flag
    ,p_dpnt_legv_id_rqd_flag         => p_dpnt_legv_id_rqd_flag
    ,p_dpnt_dsgn_lvl_cd              => p_dpnt_dsgn_lvl_cd
    ,p_pgm_stat_cd                   => p_pgm_stat_cd
    ,p_ivr_ident                     => p_ivr_ident
    ,p_pgm_typ_cd                    => p_pgm_typ_cd
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_uses_all_asmts_for_rts_flag   => p_uses_all_asmts_for_rts_flag
    ,p_url_ref_name                  => p_url_ref_name
    ,p_pgm_desc                      => p_pgm_desc
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_pgm_use_all_asnts_elig_flag   => p_pgm_use_all_asnts_elig_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_mx_dpnt_pct_prtt_lf_amt       => p_mx_dpnt_pct_prtt_lf_amt
    ,p_mx_sps_pct_prtt_lf_amt        => p_mx_sps_pct_prtt_lf_amt
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_coord_cvg_for_all_pls_flg     => p_coord_cvg_for_all_pls_flg
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_dpnt_cvg_end_dt_cd            => p_dpnt_cvg_end_dt_cd
    ,p_dpnt_cvg_end_dt_rl            => p_dpnt_cvg_end_dt_rl
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_dpnt_dsgn_no_ctfn_rqd_flag    => p_dpnt_dsgn_no_ctfn_rqd_flag
    ,p_drvbl_fctr_dpnt_elig_flag     => p_drvbl_fctr_dpnt_elig_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_info_rt_freq_cd          => p_enrt_info_rt_freq_cd
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_pgm_grp_cd                    => p_pgm_grp_cd
    ,p_pgm_uom                       => p_pgm_uom
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_alws_unrstrctd_enrt_flag      =>  p_alws_unrstrctd_enrt_flag
    ,p_enrt_cd                       =>  p_enrt_cd
    ,p_enrt_mthd_cd                  =>  p_enrt_mthd_cd
    ,p_poe_lvl_cd                    =>  p_poe_lvl_cd
    ,p_enrt_rl                       =>  p_enrt_rl
    ,p_auto_enrt_mthd_rl             =>  p_auto_enrt_mthd_rl
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_business_group_id             => p_business_group_id
    ,p_per_cvrd_cd                   =>  p_per_cvrd_cd
    ,P_vrfy_fmly_mmbr_rl             =>  P_vrfy_fmly_mmbr_rl
    ,P_vrfy_fmly_mmbr_cd             =>  P_vrfy_fmly_mmbr_cd
    ,p_short_name		     =>  p_short_name		/*FHR*/
    ,p_short_code		     =>  p_short_code		/*FHR*/
        ,p_legislation_code		     =>  p_legislation_code		/*FHR*/
        ,p_legislation_subgroup		     =>  p_legislation_subgroup		/*FHR*/
    ,p_Dflt_pgm_flag                 =>  p_Dflt_pgm_flag
    ,p_Use_prog_points_flag          =>  p_Use_prog_points_flag
    ,p_Dflt_step_cd                  =>  p_Dflt_step_cd
    ,p_Dflt_step_rl                  =>  p_Dflt_step_rl
    ,p_Update_salary_cd              =>  p_Update_salary_cd
    ,p_Use_multi_pay_rates_flag       =>  p_Use_multi_pay_rates_flag
    ,p_dflt_element_type_id          =>  p_dflt_element_type_id
    ,p_Dflt_input_value_id           =>  p_Dflt_input_value_id
    ,p_Use_scores_cd                 =>  p_Use_scores_cd
    ,p_Scores_calc_mthd_cd           =>  p_Scores_calc_mthd_cd
    ,p_Scores_calc_rl                =>  p_Scores_calc_rl
    ,p_gsp_allow_override_flag        => p_gsp_allow_override_flag
    ,p_use_variable_rates_flag        => p_use_variable_rates_flag
    ,p_salary_calc_mthd_cd        => p_salary_calc_mthd_cd
    ,p_salary_calc_mthd_rl        => p_salary_calc_mthd_rl
    ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
    ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
    ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
    ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
    ,p_pgm_attribute_category        => p_pgm_attribute_category
    ,p_pgm_attribute1                => p_pgm_attribute1
    ,p_pgm_attribute2                => p_pgm_attribute2
    ,p_pgm_attribute3                => p_pgm_attribute3
    ,p_pgm_attribute4                => p_pgm_attribute4
    ,p_pgm_attribute5                => p_pgm_attribute5
    ,p_pgm_attribute6                => p_pgm_attribute6
    ,p_pgm_attribute7                => p_pgm_attribute7
    ,p_pgm_attribute8                => p_pgm_attribute8
    ,p_pgm_attribute9                => p_pgm_attribute9
    ,p_pgm_attribute10               => p_pgm_attribute10
    ,p_pgm_attribute11               => p_pgm_attribute11
    ,p_pgm_attribute12               => p_pgm_attribute12
    ,p_pgm_attribute13               => p_pgm_attribute13
    ,p_pgm_attribute14               => p_pgm_attribute14
    ,p_pgm_attribute15               => p_pgm_attribute15
    ,p_pgm_attribute16               => p_pgm_attribute16
    ,p_pgm_attribute17               => p_pgm_attribute17
    ,p_pgm_attribute18               => p_pgm_attribute18
    ,p_pgm_attribute19               => p_pgm_attribute19
    ,p_pgm_attribute20               => p_pgm_attribute20
    ,p_pgm_attribute21               => p_pgm_attribute21
    ,p_pgm_attribute22               => p_pgm_attribute22
    ,p_pgm_attribute23               => p_pgm_attribute23
    ,p_pgm_attribute24               => p_pgm_attribute24
    ,p_pgm_attribute25               => p_pgm_attribute25
    ,p_pgm_attribute26               => p_pgm_attribute26
    ,p_pgm_attribute27               => p_pgm_attribute27
    ,p_pgm_attribute28               => p_pgm_attribute28
    ,p_pgm_attribute29               => p_pgm_attribute29
    ,p_pgm_attribute30               => p_pgm_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Program
    --
    ben_Program_bk1.create_Program_a
      (
       p_pgm_id                         =>  l_pgm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_pgm_prvds_no_auto_enrt_flag    =>  p_pgm_prvds_no_auto_enrt_flag
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_pgm_prvds_no_dflt_enrt_flag    =>  p_pgm_prvds_no_dflt_enrt_flag
      ,p_dpnt_legv_id_rqd_flag          =>  p_dpnt_legv_id_rqd_flag
      ,p_dpnt_dsgn_lvl_cd               =>  p_dpnt_dsgn_lvl_cd
      ,p_pgm_stat_cd                    =>  p_pgm_stat_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_pgm_typ_cd                     =>  p_pgm_typ_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_uses_all_asmts_for_rts_flag    =>  p_uses_all_asmts_for_rts_flag
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_pgm_desc                       =>  p_pgm_desc
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_pgm_use_all_asnts_elig_flag    =>  p_pgm_use_all_asnts_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_mx_dpnt_pct_prtt_lf_amt        =>  p_mx_dpnt_pct_prtt_lf_amt
      ,p_mx_sps_pct_prtt_lf_amt         =>  p_mx_sps_pct_prtt_lf_amt
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_coord_cvg_for_all_pls_flg      =>  p_coord_cvg_for_all_pls_flg
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dsgn_no_ctfn_rqd_flag     =>  p_dpnt_dsgn_no_ctfn_rqd_flag
      ,p_drvbl_fctr_dpnt_elig_flag      =>  p_drvbl_fctr_dpnt_elig_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_info_rt_freq_cd           =>  p_enrt_info_rt_freq_cd
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_pgm_grp_cd                     =>  p_pgm_grp_cd
      ,p_pgm_uom                        =>  p_pgm_uom
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_poe_lvl_cd                     =>  p_poe_lvl_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,p_short_name			=>  p_short_name		/*FHR*/
      ,p_short_code			=>  p_short_code		/*FHR*/
            ,p_legislation_code			=>  p_legislation_code		/*FHR*/
            ,p_legislation_subgroup			=>  p_legislation_subgroup		/*FHR*/
      ,p_Dflt_pgm_flag                  =>  p_Dflt_pgm_flag
      ,p_Use_prog_points_flag           =>  p_Use_prog_points_flag
      ,p_Dflt_step_cd                   =>  p_Dflt_step_cd
      ,p_Dflt_step_rl                   =>  p_Dflt_step_rl
      ,p_Update_salary_cd               =>  p_Update_salary_cd
      ,p_Use_multi_pay_rates_flag        =>  p_Use_multi_pay_rates_flag
      ,p_dflt_element_type_id           =>  p_dflt_element_type_id
      ,p_Dflt_input_value_id            =>  p_Dflt_input_value_id
      ,p_Use_scores_cd                  =>  p_Use_scores_cd
      ,p_Scores_calc_mthd_cd            =>  p_Scores_calc_mthd_cd
      ,p_Scores_calc_rl                 =>  p_Scores_calc_rl
      ,p_gsp_allow_override_flag         =>  p_gsp_allow_override_flag
      ,p_use_variable_rates_flag         =>  p_use_variable_rates_flag
      ,p_salary_calc_mthd_cd         =>  p_salary_calc_mthd_cd
      ,p_salary_calc_mthd_rl         =>  p_salary_calc_mthd_rl
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_pgm_attribute_category         =>  p_pgm_attribute_category
      ,p_pgm_attribute1                 =>  p_pgm_attribute1
      ,p_pgm_attribute2                 =>  p_pgm_attribute2
      ,p_pgm_attribute3                 =>  p_pgm_attribute3
      ,p_pgm_attribute4                 =>  p_pgm_attribute4
      ,p_pgm_attribute5                 =>  p_pgm_attribute5
      ,p_pgm_attribute6                 =>  p_pgm_attribute6
      ,p_pgm_attribute7                 =>  p_pgm_attribute7
      ,p_pgm_attribute8                 =>  p_pgm_attribute8
      ,p_pgm_attribute9                 =>  p_pgm_attribute9
      ,p_pgm_attribute10                =>  p_pgm_attribute10
      ,p_pgm_attribute11                =>  p_pgm_attribute11
      ,p_pgm_attribute12                =>  p_pgm_attribute12
      ,p_pgm_attribute13                =>  p_pgm_attribute13
      ,p_pgm_attribute14                =>  p_pgm_attribute14
      ,p_pgm_attribute15                =>  p_pgm_attribute15
      ,p_pgm_attribute16                =>  p_pgm_attribute16
      ,p_pgm_attribute17                =>  p_pgm_attribute17
      ,p_pgm_attribute18                =>  p_pgm_attribute18
      ,p_pgm_attribute19                =>  p_pgm_attribute19
      ,p_pgm_attribute20                =>  p_pgm_attribute20
      ,p_pgm_attribute21                =>  p_pgm_attribute21
      ,p_pgm_attribute22                =>  p_pgm_attribute22
      ,p_pgm_attribute23                =>  p_pgm_attribute23
      ,p_pgm_attribute24                =>  p_pgm_attribute24
      ,p_pgm_attribute25                =>  p_pgm_attribute25
      ,p_pgm_attribute26                =>  p_pgm_attribute26
      ,p_pgm_attribute27                =>  p_pgm_attribute27
      ,p_pgm_attribute28                =>  p_pgm_attribute28
      ,p_pgm_attribute29                =>  p_pgm_attribute29
      ,p_pgm_attribute30                =>  p_pgm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Program
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
  p_pgm_id := l_pgm_id;
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
    ROLLBACK TO create_Program;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pgm_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Program;
    raise;
    --
end create_Program;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Program >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Program
  (p_validate                       in  boolean   default false
  ,p_pgm_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_pgm_prvds_no_auto_enrt_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dob_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_pgm_prvds_no_dflt_enrt_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_legv_id_rqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_lvl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pgm_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_pgm_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_uses_all_asmts_for_rts_flag    in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_pgm_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_pgm_use_all_asnts_elig_flag    in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_mx_dpnt_pct_prtt_lf_amt        in  number    default hr_api.g_number
  ,p_mx_sps_pct_prtt_lf_amt         in  number    default hr_api.g_number
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_coord_cvg_for_all_pls_flg      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_dpnt_dsgn_no_ctfn_rqd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_dpnt_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_info_rt_freq_cd           in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_pgm_grp_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_pgm_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_poe_lvl_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,P_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,P_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,P_short_name                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
  ,P_short_code                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
    ,P_legislation_code                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
    ,P_legislation_subgroup                     in  varchar2  default hr_api.g_varchar2     /*FHR*/
  ,p_Dflt_pgm_flag                  in  Varchar2  default hr_api.g_varchar2
  ,p_Use_prog_points_flag           in  Varchar2  default hr_api.g_varchar2
  ,p_Dflt_step_cd                   in  Varchar2  default hr_api.g_varchar2
  ,p_Dflt_step_rl                   in  number    default hr_api.g_number
  ,p_Update_salary_cd               in  Varchar2  default hr_api.g_varchar2
  ,p_Use_multi_pay_rates_flag       in  Varchar2  default hr_api.g_varchar2
  ,p_dflt_element_type_id           in  number    default hr_api.g_number
  ,p_Dflt_input_value_id            in  number    default hr_api.g_number
  ,p_Use_scores_cd                  in  Varchar2  default hr_api.g_varchar2
  ,p_Scores_calc_mthd_cd            in  Varchar2  default hr_api.g_varchar2
  ,p_Scores_calc_rl                 in  number    default hr_api.g_number
  ,p_gsp_allow_override_flag         in  varchar2  default hr_api.g_varchar2
  ,p_use_variable_rates_flag         in  varchar2  default hr_api.g_varchar2
  ,p_salary_calc_mthd_cd         in  varchar2  default hr_api.g_varchar2
  ,p_salary_calc_mthd_rl         in  number  default hr_api.g_number
  ,p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default hr_api.g_varchar2
  ,p_dpnt_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2
  ,p_pgm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pgm_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Program';
  l_object_version_number ben_pgm_f.object_version_number%TYPE;
  l_effective_start_date ben_pgm_f.effective_start_date%TYPE;
  l_effective_end_date ben_pgm_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Program;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Program
    --
    ben_Program_bk2.update_Program_b
      (
       p_pgm_id                         =>  p_pgm_id
      ,p_name                           =>  p_name
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_pgm_prvds_no_auto_enrt_flag    =>  p_pgm_prvds_no_auto_enrt_flag
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_pgm_prvds_no_dflt_enrt_flag    =>  p_pgm_prvds_no_dflt_enrt_flag
      ,p_dpnt_legv_id_rqd_flag          =>  p_dpnt_legv_id_rqd_flag
      ,p_dpnt_dsgn_lvl_cd               =>  p_dpnt_dsgn_lvl_cd
      ,p_pgm_stat_cd                    =>  p_pgm_stat_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_pgm_typ_cd                     =>  p_pgm_typ_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_uses_all_asmts_for_rts_flag    =>  p_uses_all_asmts_for_rts_flag
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_pgm_desc                       =>  p_pgm_desc
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_pgm_use_all_asnts_elig_flag    =>  p_pgm_use_all_asnts_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_mx_dpnt_pct_prtt_lf_amt        =>  p_mx_dpnt_pct_prtt_lf_amt
      ,p_mx_sps_pct_prtt_lf_amt         =>  p_mx_sps_pct_prtt_lf_amt
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_coord_cvg_for_all_pls_flg      =>  p_coord_cvg_for_all_pls_flg
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dsgn_no_ctfn_rqd_flag     =>  p_dpnt_dsgn_no_ctfn_rqd_flag
      ,p_drvbl_fctr_dpnt_elig_flag      =>  p_drvbl_fctr_dpnt_elig_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_info_rt_freq_cd           =>  p_enrt_info_rt_freq_cd
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_pgm_grp_cd                     =>  p_pgm_grp_cd
      ,p_pgm_uom                        =>  p_pgm_uom
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_poe_lvl_cd                     =>  p_poe_lvl_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,p_short_name			=>  p_short_name      	 	/*FHR*/
      ,p_short_code			=>  p_short_code      	 	/*FHR*/
            ,p_legislation_code			=>  p_legislation_code      	 	/*FHR*/
            ,p_legislation_subgroup			=>  p_legislation_subgroup      	 	/*FHR*/
      ,p_Dflt_pgm_flag                  =>  p_Dflt_pgm_flag
      ,p_Use_prog_points_flag           =>  p_Use_prog_points_flag
      ,p_Dflt_step_cd                   =>  p_Dflt_step_cd
      ,p_Dflt_step_rl                   =>  p_Dflt_step_rl
      ,p_Update_salary_cd               =>  p_Update_salary_cd
      ,p_Use_multi_pay_rates_flag        =>  p_Use_multi_pay_rates_flag
      ,p_dflt_element_type_id           =>  p_dflt_element_type_id
      ,p_Dflt_input_value_id            =>  p_Dflt_input_value_id
      ,p_Use_scores_cd                  =>  p_Use_scores_cd
      ,p_Scores_calc_mthd_cd            =>  p_Scores_calc_mthd_cd
      ,p_Scores_calc_rl                 =>  p_Scores_calc_rl
      ,p_gsp_allow_override_flag         =>  p_gsp_allow_override_flag
      ,p_use_variable_rates_flag         =>  p_use_variable_rates_flag
      ,p_salary_calc_mthd_cd         =>  p_salary_calc_mthd_cd
      ,p_salary_calc_mthd_rl         =>  p_salary_calc_mthd_rl
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_pgm_attribute_category         =>  p_pgm_attribute_category
      ,p_pgm_attribute1                 =>  p_pgm_attribute1
      ,p_pgm_attribute2                 =>  p_pgm_attribute2
      ,p_pgm_attribute3                 =>  p_pgm_attribute3
      ,p_pgm_attribute4                 =>  p_pgm_attribute4
      ,p_pgm_attribute5                 =>  p_pgm_attribute5
      ,p_pgm_attribute6                 =>  p_pgm_attribute6
      ,p_pgm_attribute7                 =>  p_pgm_attribute7
      ,p_pgm_attribute8                 =>  p_pgm_attribute8
      ,p_pgm_attribute9                 =>  p_pgm_attribute9
      ,p_pgm_attribute10                =>  p_pgm_attribute10
      ,p_pgm_attribute11                =>  p_pgm_attribute11
      ,p_pgm_attribute12                =>  p_pgm_attribute12
      ,p_pgm_attribute13                =>  p_pgm_attribute13
      ,p_pgm_attribute14                =>  p_pgm_attribute14
      ,p_pgm_attribute15                =>  p_pgm_attribute15
      ,p_pgm_attribute16                =>  p_pgm_attribute16
      ,p_pgm_attribute17                =>  p_pgm_attribute17
      ,p_pgm_attribute18                =>  p_pgm_attribute18
      ,p_pgm_attribute19                =>  p_pgm_attribute19
      ,p_pgm_attribute20                =>  p_pgm_attribute20
      ,p_pgm_attribute21                =>  p_pgm_attribute21
      ,p_pgm_attribute22                =>  p_pgm_attribute22
      ,p_pgm_attribute23                =>  p_pgm_attribute23
      ,p_pgm_attribute24                =>  p_pgm_attribute24
      ,p_pgm_attribute25                =>  p_pgm_attribute25
      ,p_pgm_attribute26                =>  p_pgm_attribute26
      ,p_pgm_attribute27                =>  p_pgm_attribute27
      ,p_pgm_attribute28                =>  p_pgm_attribute28
      ,p_pgm_attribute29                =>  p_pgm_attribute29
      ,p_pgm_attribute30                =>  p_pgm_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Program
    --
  end;
  --
  ben_pgm_upd.upd
    (
     p_pgm_id                        => p_pgm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_dpnt_adrs_rqd_flag            => p_dpnt_adrs_rqd_flag
    ,p_pgm_prvds_no_auto_enrt_flag   => p_pgm_prvds_no_auto_enrt_flag
    ,p_dpnt_dob_rqd_flag             => p_dpnt_dob_rqd_flag
    ,p_pgm_prvds_no_dflt_enrt_flag   => p_pgm_prvds_no_dflt_enrt_flag
    ,p_dpnt_legv_id_rqd_flag         => p_dpnt_legv_id_rqd_flag
    ,p_dpnt_dsgn_lvl_cd              => p_dpnt_dsgn_lvl_cd
    ,p_pgm_stat_cd                   => p_pgm_stat_cd
    ,p_ivr_ident                     => p_ivr_ident
    ,p_pgm_typ_cd                    => p_pgm_typ_cd
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_uses_all_asmts_for_rts_flag   => p_uses_all_asmts_for_rts_flag
    ,p_url_ref_name                  => p_url_ref_name
    ,p_pgm_desc                      => p_pgm_desc
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_pgm_use_all_asnts_elig_flag   => p_pgm_use_all_asnts_elig_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_mx_dpnt_pct_prtt_lf_amt       => p_mx_dpnt_pct_prtt_lf_amt
    ,p_mx_sps_pct_prtt_lf_amt        => p_mx_sps_pct_prtt_lf_amt
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_coord_cvg_for_all_pls_flg     => p_coord_cvg_for_all_pls_flg
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_dpnt_cvg_end_dt_cd            => p_dpnt_cvg_end_dt_cd
    ,p_dpnt_cvg_end_dt_rl            => p_dpnt_cvg_end_dt_rl
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_dpnt_dsgn_no_ctfn_rqd_flag    => p_dpnt_dsgn_no_ctfn_rqd_flag
    ,p_drvbl_fctr_dpnt_elig_flag     => p_drvbl_fctr_dpnt_elig_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_info_rt_freq_cd          => p_enrt_info_rt_freq_cd
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_pgm_grp_cd                    => p_pgm_grp_cd
    ,p_pgm_uom                       => p_pgm_uom
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_alws_unrstrctd_enrt_flag      =>  p_alws_unrstrctd_enrt_flag
    ,p_enrt_cd                       =>  p_enrt_cd
    ,p_enrt_mthd_cd                  =>  p_enrt_mthd_cd
    ,p_poe_lvl_cd                    =>  p_poe_lvl_cd
    ,p_enrt_rl                       =>  p_enrt_rl
    ,p_auto_enrt_mthd_rl             =>  p_auto_enrt_mthd_rl
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_business_group_id             => p_business_group_id
    ,p_per_cvrd_cd                   =>  p_per_cvrd_cd
    ,P_vrfy_fmly_mmbr_rl             =>  P_vrfy_fmly_mmbr_rl
    ,P_vrfy_fmly_mmbr_cd             =>  P_vrfy_fmly_mmbr_cd
    ,p_short_name	             =>  p_short_name      	 	/*FHR*/
    ,p_short_code		     =>  p_short_code      	 	/*FHR*/
        ,p_legislation_code		     =>  p_legislation_code      	 	/*FHR*/
        ,p_legislation_subgroup		     =>  p_legislation_subgroup      	 	/*FHR*/
    ,p_Dflt_pgm_flag                 =>  p_Dflt_pgm_flag
    ,p_Use_prog_points_flag          =>  p_Use_prog_points_flag
    ,p_Dflt_step_cd                  =>  p_Dflt_step_cd
    ,p_Dflt_step_rl                  =>  p_Dflt_step_rl
    ,p_Update_salary_cd              =>  p_Update_salary_cd
    ,p_Use_multi_pay_rates_flag       =>  p_Use_multi_pay_rates_flag
    ,p_dflt_element_type_id          =>  p_dflt_element_type_id
    ,p_Dflt_input_value_id           =>  p_Dflt_input_value_id
    ,p_Use_scores_cd                 =>  p_Use_scores_cd
    ,p_Scores_calc_mthd_cd           =>  p_Scores_calc_mthd_cd
    ,p_Scores_calc_rl                =>  p_Scores_calc_rl
    ,p_gsp_allow_override_flag        => p_gsp_allow_override_flag
    ,p_use_variable_rates_flag        => p_use_variable_rates_flag
    ,p_salary_calc_mthd_cd        => p_salary_calc_mthd_cd
    ,p_salary_calc_mthd_rl        => p_salary_calc_mthd_rl
    ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
    ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
    ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
    ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
    ,p_pgm_attribute_category        => p_pgm_attribute_category
    ,p_pgm_attribute1                => p_pgm_attribute1
    ,p_pgm_attribute2                => p_pgm_attribute2
    ,p_pgm_attribute3                => p_pgm_attribute3
    ,p_pgm_attribute4                => p_pgm_attribute4
    ,p_pgm_attribute5                => p_pgm_attribute5
    ,p_pgm_attribute6                => p_pgm_attribute6
    ,p_pgm_attribute7                => p_pgm_attribute7
    ,p_pgm_attribute8                => p_pgm_attribute8
    ,p_pgm_attribute9                => p_pgm_attribute9
    ,p_pgm_attribute10               => p_pgm_attribute10
    ,p_pgm_attribute11               => p_pgm_attribute11
    ,p_pgm_attribute12               => p_pgm_attribute12
    ,p_pgm_attribute13               => p_pgm_attribute13
    ,p_pgm_attribute14               => p_pgm_attribute14
    ,p_pgm_attribute15               => p_pgm_attribute15
    ,p_pgm_attribute16               => p_pgm_attribute16
    ,p_pgm_attribute17               => p_pgm_attribute17
    ,p_pgm_attribute18               => p_pgm_attribute18
    ,p_pgm_attribute19               => p_pgm_attribute19
    ,p_pgm_attribute20               => p_pgm_attribute20
    ,p_pgm_attribute21               => p_pgm_attribute21
    ,p_pgm_attribute22               => p_pgm_attribute22
    ,p_pgm_attribute23               => p_pgm_attribute23
    ,p_pgm_attribute24               => p_pgm_attribute24
    ,p_pgm_attribute25               => p_pgm_attribute25
    ,p_pgm_attribute26               => p_pgm_attribute26
    ,p_pgm_attribute27               => p_pgm_attribute27
    ,p_pgm_attribute28               => p_pgm_attribute28
    ,p_pgm_attribute29               => p_pgm_attribute29
    ,p_pgm_attribute30               => p_pgm_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Program
    --
    ben_Program_bk2.update_Program_a
      (
       p_pgm_id                         =>  p_pgm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_pgm_prvds_no_auto_enrt_flag    =>  p_pgm_prvds_no_auto_enrt_flag
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_pgm_prvds_no_dflt_enrt_flag    =>  p_pgm_prvds_no_dflt_enrt_flag
      ,p_dpnt_legv_id_rqd_flag          =>  p_dpnt_legv_id_rqd_flag
      ,p_dpnt_dsgn_lvl_cd               =>  p_dpnt_dsgn_lvl_cd
      ,p_pgm_stat_cd                    =>  p_pgm_stat_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_pgm_typ_cd                     =>  p_pgm_typ_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_uses_all_asmts_for_rts_flag    =>  p_uses_all_asmts_for_rts_flag
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_pgm_desc                       =>  p_pgm_desc
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_pgm_use_all_asnts_elig_flag    =>  p_pgm_use_all_asnts_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_mx_dpnt_pct_prtt_lf_amt        =>  p_mx_dpnt_pct_prtt_lf_amt
      ,p_mx_sps_pct_prtt_lf_amt         =>  p_mx_sps_pct_prtt_lf_amt
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_coord_cvg_for_all_pls_flg      =>  p_coord_cvg_for_all_pls_flg
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dsgn_no_ctfn_rqd_flag     =>  p_dpnt_dsgn_no_ctfn_rqd_flag
      ,p_drvbl_fctr_dpnt_elig_flag      =>  p_drvbl_fctr_dpnt_elig_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_info_rt_freq_cd           =>  p_enrt_info_rt_freq_cd
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_pgm_grp_cd                     =>  p_pgm_grp_cd
      ,p_pgm_uom                        =>  p_pgm_uom
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_poe_lvl_cd                     =>  p_poe_lvl_cd
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,P_vrfy_fmly_mmbr_rl              =>  P_vrfy_fmly_mmbr_rl
      ,P_vrfy_fmly_mmbr_cd              =>  P_vrfy_fmly_mmbr_cd
      ,p_short_name			=>  p_short_name      	 	/*FHR*/
      ,p_short_code			=>  p_short_code      	 	/*FHR*/
            ,p_legislation_code			=>  p_legislation_code      	 	/*FHR*/
            ,p_legislation_subgroup			=>  p_legislation_subgroup      	 	/*FHR*/
      ,p_Dflt_pgm_flag                  =>  p_Dflt_pgm_flag
      ,p_Use_prog_points_flag           =>  p_Use_prog_points_flag
      ,p_Dflt_step_cd                   =>  p_Dflt_step_cd
      ,p_Dflt_step_rl                   =>  p_Dflt_step_rl
      ,p_Update_salary_cd               =>  p_Update_salary_cd
      ,p_Use_multi_pay_rates_flag        =>  p_Use_multi_pay_rates_flag
      ,p_dflt_element_type_id           =>  p_dflt_element_type_id
      ,p_Dflt_input_value_id            =>  p_Dflt_input_value_id
      ,p_Use_scores_cd                  =>  p_Use_scores_cd
      ,p_Scores_calc_mthd_cd            =>  p_Scores_calc_mthd_cd
      ,p_Scores_calc_rl                 =>  p_Scores_calc_rl
      ,p_gsp_allow_override_flag         =>  p_gsp_allow_override_flag
      ,p_use_variable_rates_flag         =>  p_use_variable_rates_flag
      ,p_salary_calc_mthd_cd         =>  p_salary_calc_mthd_cd
      ,p_salary_calc_mthd_rl         =>  p_salary_calc_mthd_rl
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_pgm_attribute_category         =>  p_pgm_attribute_category
      ,p_pgm_attribute1                 =>  p_pgm_attribute1
      ,p_pgm_attribute2                 =>  p_pgm_attribute2
      ,p_pgm_attribute3                 =>  p_pgm_attribute3
      ,p_pgm_attribute4                 =>  p_pgm_attribute4
      ,p_pgm_attribute5                 =>  p_pgm_attribute5
      ,p_pgm_attribute6                 =>  p_pgm_attribute6
      ,p_pgm_attribute7                 =>  p_pgm_attribute7
      ,p_pgm_attribute8                 =>  p_pgm_attribute8
      ,p_pgm_attribute9                 =>  p_pgm_attribute9
      ,p_pgm_attribute10                =>  p_pgm_attribute10
      ,p_pgm_attribute11                =>  p_pgm_attribute11
      ,p_pgm_attribute12                =>  p_pgm_attribute12
      ,p_pgm_attribute13                =>  p_pgm_attribute13
      ,p_pgm_attribute14                =>  p_pgm_attribute14
      ,p_pgm_attribute15                =>  p_pgm_attribute15
      ,p_pgm_attribute16                =>  p_pgm_attribute16
      ,p_pgm_attribute17                =>  p_pgm_attribute17
      ,p_pgm_attribute18                =>  p_pgm_attribute18
      ,p_pgm_attribute19                =>  p_pgm_attribute19
      ,p_pgm_attribute20                =>  p_pgm_attribute20
      ,p_pgm_attribute21                =>  p_pgm_attribute21
      ,p_pgm_attribute22                =>  p_pgm_attribute22
      ,p_pgm_attribute23                =>  p_pgm_attribute23
      ,p_pgm_attribute24                =>  p_pgm_attribute24
      ,p_pgm_attribute25                =>  p_pgm_attribute25
      ,p_pgm_attribute26                =>  p_pgm_attribute26
      ,p_pgm_attribute27                =>  p_pgm_attribute27
      ,p_pgm_attribute28                =>  p_pgm_attribute28
      ,p_pgm_attribute29                =>  p_pgm_attribute29
      ,p_pgm_attribute30                =>  p_pgm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Program
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
    ROLLBACK TO update_Program;
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
    ROLLBACK TO update_Program;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Program;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Program >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Program
  (p_validate                       in  boolean  default false
  ,p_pgm_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Program';
  l_object_version_number ben_pgm_f.object_version_number%TYPE;
  l_effective_start_date ben_pgm_f.effective_start_date%TYPE;
  l_effective_end_date ben_pgm_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Program;
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
    -- Start of API User Hook for the before hook of delete_Program
    --
    ben_Program_bk3.delete_Program_b
      (
       p_pgm_id                         =>  p_pgm_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Program'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Program
    --
  end;
  --
  ben_pgm_del.del
    (
     p_pgm_id                        => p_pgm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Program
    --
    ben_Program_bk3.delete_Program_a
      (
       p_pgm_id                         =>  p_pgm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Program'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Program
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
    ROLLBACK TO delete_Program;
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
    ROLLBACK TO delete_Program;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Program;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pgm_id                   in     number
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
  ben_pgm_shd.lck
    (
      p_pgm_id                 => p_pgm_id
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
end ben_Program_api;

/
