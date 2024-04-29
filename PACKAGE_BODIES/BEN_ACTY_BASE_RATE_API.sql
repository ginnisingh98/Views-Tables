--------------------------------------------------------
--  DDL for Package Body BEN_ACTY_BASE_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTY_BASE_RATE_API" as
/* $Header: beabrapi.pkb 120.3 2006/01/19 08:04:50 swjain noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_acty_base_rate_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_acty_base_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_acty_base_rate
  (p_validate                       in  boolean   default false
  ,p_acty_base_rt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num			    in number     default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_sub_acty_typ_cd                in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag    in  varchar2  default 'N'
  ,p_asn_on_enrt_flag               in  varchar2  default 'N'
  ,p_abv_mx_elcn_val_alwd_flag      in  varchar2  default 'N'
  ,p_blw_mn_elcn_alwd_flag          in  varchar2  default 'N'
  ,p_dsply_on_enrt_flag             in  varchar2  default 'N'
  ,p_parnt_chld_cd                  in  varchar2  default null
  ,p_use_calc_acty_bs_rt_flag       in  varchar2  default 'Y'
  ,p_uses_ded_sched_flag            in  varchar2  default 'N'
  ,p_uses_varbl_rt_flag             in  varchar2  default 'N'
  ,p_vstg_sched_apls_flag           in  varchar2  default 'N'
  ,p_rt_mlt_cd                      in  varchar2  default null
  ,p_proc_each_pp_dflt_flag         in  varchar2  default 'N'
  ,p_prdct_flx_cr_when_elig_flag    in  varchar2  default 'N'
  ,p_no_std_rt_used_flag            in  varchar2  default 'N'
  ,p_rcrrg_cd                       in  varchar2  default null
  ,p_mn_elcn_val                    in  number    default null
  ,p_mx_elcn_val                    in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_ptd_comp_lvl_fctr_id           in  number    default null
  ,p_clm_comp_lvl_fctr_id           in  number    default null
  ,p_entr_ann_val_flag              in  varchar2  default 'N'
  ,p_ann_mn_elcn_val                in  number    default null
  ,p_ann_mx_elcn_val                in  number    default null
  ,p_wsh_rl_dy_mo_num               in  number    default null
  ,p_uses_pymt_sched_flag           in  varchar2  default 'N'
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_incrmt_elcn_val                in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_val_ovrid_alwd_flag            in  varchar2  default 'N'
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default null
  ,p_acty_base_rt_stat_cd           in  varchar2  default null
  ,p_procg_src_cd                   in  varchar2  default null
  ,p_dflt_val                       in  number    default null
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_frgn_erg_ded_typ_cd            in  varchar2  default null
  ,p_frgn_erg_ded_name              in  varchar2  default null
  ,p_frgn_erg_ded_ident             in  varchar2  default null
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_prtl_mo_det_mthd_rl            in  number    default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default 'N'
  ,p_prtl_mo_eff_dt_det_rl          in  number    default null
  ,p_rndg_rl                        in  number    default null
  ,p_val_calc_rl                    in  number    default null
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_prtl_mo_eff_dt_det_cd          in  varchar2  default null
  ,p_only_one_bal_typ_alwd_flag     in  varchar2  default 'N'
  ,p_rt_usg_cd                      in  varchar2  default null
  ,p_prort_mn_ann_elcn_val_cd       in  varchar2  default null
  ,p_prort_mn_ann_elcn_val_rl       in  number    default null
  ,p_prort_mx_ann_elcn_val_cd       in  varchar2  default null
  ,p_prort_mx_ann_elcn_val_rl       in  number    default null
  ,p_one_ann_pymt_cd                in  varchar2  default null
  ,p_det_pl_ytd_cntrs_cd            in  varchar2  default null
  ,p_asmt_to_use_cd                 in  varchar2  default null
  ,p_ele_rqd_flag                   in  varchar2  default 'Y'
  ,p_subj_to_imptd_incm_flag        in  varchar2  default 'N'
  ,p_element_type_id                in  number    default null
  ,p_input_value_id                 in  number    default null
  ,p_input_va_calc_rl              in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_parnt_acty_base_rt_id          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_vstg_for_acty_rt_id            in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_TTL_COMP_LVL_FCTR_ID           in  number    default null
  ,p_COST_ALLOCATION_KEYFLEX_ID     in  number    default null
  ,p_ALWS_CHG_CD                    in  varchar2    default null
  ,p_ele_entry_val_cd               in  varchar2    default null
  ,p_pay_rate_grade_rule_id         in  number    default null
  ,p_rate_periodization_cd               in  varchar2  default null
  ,p_rate_periodization_rl               in  number    default null
  ,p_mn_mx_elcn_rl                   in number     default null
  ,p_mapping_table_name             in varchar2    default null
  ,p_mapping_table_pk_id            in number       default null
  ,p_business_group_id              in  number    default null
  ,p_context_pgm_id                 in number     default null
  ,p_context_pl_id                  in number     default null
  ,p_context_opt_id                 in number     default null
  ,p_element_det_rl                 in  number    default null
  ,p_currency_det_cd                in  varchar2  default null
  ,p_abr_attribute_category         in  varchar2  default null
  ,p_abr_attribute1                 in  varchar2  default null
  ,p_abr_attribute2                 in  varchar2  default null
  ,p_abr_attribute3                 in  varchar2  default null
  ,p_abr_attribute4                 in  varchar2  default null
  ,p_abr_attribute5                 in  varchar2  default null
  ,p_abr_attribute6                 in  varchar2  default null
  ,p_abr_attribute7                 in  varchar2  default null
  ,p_abr_attribute8                 in  varchar2  default null
  ,p_abr_attribute9                 in  varchar2  default null
  ,p_abr_attribute10                in  varchar2  default null
  ,p_abr_attribute11                in  varchar2  default null
  ,p_abr_attribute12                in  varchar2  default null
  ,p_abr_attribute13                in  varchar2  default null
  ,p_abr_attribute14                in  varchar2  default null
  ,p_abr_attribute15                in  varchar2  default null
  ,p_abr_attribute16                in  varchar2  default null
  ,p_abr_attribute17                in  varchar2  default null
  ,p_abr_attribute18                in  varchar2  default null
  ,p_abr_attribute19                in  varchar2  default null
  ,p_abr_attribute20                in  varchar2  default null
  ,p_abr_attribute21                in  varchar2  default null
  ,p_abr_attribute22                in  varchar2  default null
  ,p_abr_attribute23                in  varchar2  default null
  ,p_abr_attribute24                in  varchar2  default null
  ,p_abr_attribute25                in  varchar2  default null
  ,p_abr_attribute26                in  varchar2  default null
  ,p_abr_attribute27                in  varchar2  default null
  ,p_abr_attribute28                in  varchar2  default null
  ,p_abr_attribute29                in  varchar2  default null
  ,p_abr_attribute30                in  varchar2  default null
  ,p_abr_seq_num                    in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_acty_base_rt_id ben_acty_base_rt_f.acty_base_rt_id%TYPE;
  l_effective_start_date ben_acty_base_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_base_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_acty_base_rate';
  l_object_version_number ben_acty_base_rt_f.object_version_number%TYPE;
  --

  l_use_to_calc_net_flx_cr_flag ben_acty_base_rt_f.use_to_calc_net_flx_cr_flag%TYPE := p_use_to_calc_net_flx_cr_flag;
  l_asn_on_enrt_flag            ben_acty_base_rt_f.asn_on_enrt_flag%TYPE            := p_asn_on_enrt_flag;
  l_entr_val_at_enrt_flag       ben_acty_base_rt_f.entr_val_at_enrt_flag%TYPE       := p_entr_val_at_enrt_flag;
  l_prdct_flx_cr_when_elig_flag ben_acty_base_rt_f.prdct_flx_cr_when_elig_flag%TYPE := p_prdct_flx_cr_when_elig_flag;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_acty_base_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_acty_base_rate
    --
    ben_acty_base_rate_bk1.create_acty_base_rate_b
      (
       p_ordr_num                    =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_sub_acty_typ_cd                =>  p_sub_acty_typ_cd
      ,p_name                           =>  p_name
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_use_to_calc_net_flx_cr_flag    =>  p_use_to_calc_net_flx_cr_flag
      ,p_asn_on_enrt_flag               =>  p_asn_on_enrt_flag
      ,p_abv_mx_elcn_val_alwd_flag      =>  p_abv_mx_elcn_val_alwd_flag
      ,p_blw_mn_elcn_alwd_flag          =>  p_blw_mn_elcn_alwd_flag
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_parnt_chld_cd                  =>  p_parnt_chld_cd
      ,p_use_calc_acty_bs_rt_flag       =>  p_use_calc_acty_bs_rt_flag
      ,p_uses_ded_sched_flag            =>  p_uses_ded_sched_flag
      ,p_uses_varbl_rt_flag             =>  p_uses_varbl_rt_flag
      ,p_vstg_sched_apls_flag           =>  p_vstg_sched_apls_flag
      ,p_rt_mlt_cd                      =>  p_rt_mlt_cd
      ,p_proc_each_pp_dflt_flag         =>  p_proc_each_pp_dflt_flag
      ,p_prdct_flx_cr_when_elig_flag    =>  p_prdct_flx_cr_when_elig_flag
      ,p_no_std_rt_used_flag            =>  p_no_std_rt_used_flag
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ptd_comp_lvl_fctr_id           =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id           =>  p_clm_comp_lvl_fctr_id
      ,p_entr_ann_val_flag              =>  p_entr_ann_val_flag
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_uses_pymt_sched_flag           =>  p_uses_pymt_sched_flag
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_val                            =>  p_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_acty_base_rt_stat_cd           =>  p_acty_base_rt_stat_cd
      ,p_procg_src_cd                   =>  p_procg_src_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_frgn_erg_ded_typ_cd            =>  p_frgn_erg_ded_typ_cd
      ,p_frgn_erg_ded_name              =>  p_frgn_erg_ded_name
      ,p_frgn_erg_ded_ident             =>  p_frgn_erg_ded_ident
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_prtl_mo_eff_dt_det_rl          =>  p_prtl_mo_eff_dt_det_rl
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_prtl_mo_eff_dt_det_cd          =>  p_prtl_mo_eff_dt_det_cd
      ,p_only_one_bal_typ_alwd_flag     =>  p_only_one_bal_typ_alwd_flag
      ,p_rt_usg_cd                      =>  p_rt_usg_cd
      ,p_prort_mn_ann_elcn_val_cd       =>  p_prort_mn_ann_elcn_val_cd
      ,p_prort_mn_ann_elcn_val_rl       =>  p_prort_mn_ann_elcn_val_rl
      ,p_prort_mx_ann_elcn_val_cd       =>  p_prort_mx_ann_elcn_val_cd
      ,p_prort_mx_ann_elcn_val_rl       =>  p_prort_mx_ann_elcn_val_rl
      ,p_one_ann_pymt_cd                =>  p_one_ann_pymt_cd
      ,p_det_pl_ytd_cntrs_cd            =>  p_det_pl_ytd_cntrs_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_ele_rqd_flag                   =>  p_ele_rqd_flag
      ,p_subj_to_imptd_incm_flag        =>  p_subj_to_imptd_incm_flag
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_va_calc_rl              =>  p_input_va_calc_rl
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_vstg_for_acty_rt_id            =>  p_vstg_for_acty_rt_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_TTL_COMP_LVL_FCTR_ID           => p_TTL_COMP_LVL_FCTR_ID
      ,p_COST_ALLOCATION_KEYFLEX_ID     => p_COST_ALLOCATION_KEYFLEX_ID
      ,p_ALWS_CHG_CD                    => p_ALWS_CHG_CD
      ,p_ele_entry_val_cd               => p_ele_entry_val_cd
      ,p_pay_rate_grade_rule_id         => p_pay_rate_grade_rule_id
      ,p_rate_periodization_cd               => p_rate_periodization_cd
      ,p_rate_periodization_rl               => p_rate_periodization_rl
      ,p_mn_mx_elcn_rl			=> p_mn_mx_elcn_rl
      ,p_mapping_table_name             => p_mapping_table_name
      ,p_mapping_table_pk_id     	=> p_mapping_table_pk_id
      ,p_business_group_id              => p_business_group_id
      ,p_context_pgm_id                 => p_context_pgm_id
      ,p_context_pl_id                  => p_context_pl_id
      ,p_context_opt_id                 => p_context_opt_id
      ,p_element_det_rl                 => p_element_det_rl
      ,p_currency_det_cd                => p_currency_det_cd
      ,p_abr_attribute_category         => p_abr_attribute_category
      ,p_abr_attribute1                 => p_abr_attribute1
      ,p_abr_attribute2                 => p_abr_attribute2
      ,p_abr_attribute3                 => p_abr_attribute3
      ,p_abr_attribute4                 => p_abr_attribute4
      ,p_abr_attribute5                 => p_abr_attribute5
      ,p_abr_attribute6                 => p_abr_attribute6
      ,p_abr_attribute7                 => p_abr_attribute7
      ,p_abr_attribute8                 => p_abr_attribute8
      ,p_abr_attribute9                 => p_abr_attribute9
      ,p_abr_attribute10                => p_abr_attribute10
      ,p_abr_attribute11                => p_abr_attribute11
      ,p_abr_attribute12                =>  p_abr_attribute12
      ,p_abr_attribute13                =>  p_abr_attribute13
      ,p_abr_attribute14                =>  p_abr_attribute14
      ,p_abr_attribute15                =>  p_abr_attribute15
      ,p_abr_attribute16                =>  p_abr_attribute16
      ,p_abr_attribute17                =>  p_abr_attribute17
      ,p_abr_attribute18                =>  p_abr_attribute18
      ,p_abr_attribute19                =>  p_abr_attribute19
      ,p_abr_attribute20                =>  p_abr_attribute20
      ,p_abr_attribute21                =>  p_abr_attribute21
      ,p_abr_attribute22                =>  p_abr_attribute22
      ,p_abr_attribute23                =>  p_abr_attribute23
      ,p_abr_attribute24                =>  p_abr_attribute24
      ,p_abr_attribute25                =>  p_abr_attribute25
      ,p_abr_attribute26                =>  p_abr_attribute26
      ,p_abr_attribute27                =>  p_abr_attribute27
      ,p_abr_attribute28                =>  p_abr_attribute28
      ,p_abr_attribute29                =>  p_abr_attribute29
      ,p_abr_attribute30                =>  p_abr_attribute30
      ,p_abr_seq_num                    =>  p_abr_seq_num
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_acty_base_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_acty_base_rate
    --
  end;
  --

  --  check the usage code if it is FLXCR then variable are changed
  If P_rt_usg_cd = 'FLXCR' then
     l_use_to_calc_net_flx_cr_flag   := 'Y' ;
     l_asn_on_enrt_flag              := 'Y' ;
     l_entr_val_at_enrt_flag         := 'N' ;
     l_prdct_flx_cr_when_elig_flag   := 'Y' ;
  end if ;


  ---
  ben_abr_ins.ins
    (
     p_acty_base_rt_id               => l_acty_base_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num			     => p_ordr_num
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_sub_acty_typ_cd               => p_sub_acty_typ_cd
    ,p_name                          => p_name
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_use_to_calc_net_flx_cr_flag   => l_use_to_calc_net_flx_cr_flag
    ,p_asn_on_enrt_flag              => l_asn_on_enrt_flag
    ,p_abv_mx_elcn_val_alwd_flag     => p_abv_mx_elcn_val_alwd_flag
    ,p_blw_mn_elcn_alwd_flag         => p_blw_mn_elcn_alwd_flag
    ,p_dsply_on_enrt_flag            => p_dsply_on_enrt_flag
    ,p_parnt_chld_cd                 => p_parnt_chld_cd
    ,p_use_calc_acty_bs_rt_flag      => p_use_calc_acty_bs_rt_flag
    ,p_uses_ded_sched_flag           => p_uses_ded_sched_flag
    ,p_uses_varbl_rt_flag            => p_uses_varbl_rt_flag
    ,p_vstg_sched_apls_flag          => p_vstg_sched_apls_flag
    ,p_rt_mlt_cd                     => p_rt_mlt_cd
    ,p_proc_each_pp_dflt_flag        => p_proc_each_pp_dflt_flag
    ,p_prdct_flx_cr_when_elig_flag   => l_prdct_flx_cr_when_elig_flag
    ,p_no_std_rt_used_flag           => p_no_std_rt_used_flag
    ,p_rcrrg_cd                      => p_rcrrg_cd
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_ptd_comp_lvl_fctr_id          => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id          => p_clm_comp_lvl_fctr_id
    ,p_entr_ann_val_flag             => p_entr_ann_val_flag
    ,p_ann_mn_elcn_val               => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val               => p_ann_mx_elcn_val
    ,p_wsh_rl_dy_mo_num              => p_wsh_rl_dy_mo_num
    ,p_uses_pymt_sched_flag          => p_uses_pymt_sched_flag
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_val                           => p_val
    ,p_incrmt_elcn_val               => p_incrmt_elcn_val
    ,p_rndg_cd                       => p_rndg_cd
    ,p_val_ovrid_alwd_flag           => p_val_ovrid_alwd_flag
    ,p_prtl_mo_det_mthd_cd           => p_prtl_mo_det_mthd_cd
    ,p_acty_base_rt_stat_cd          => p_acty_base_rt_stat_cd
    ,p_procg_src_cd                  => p_procg_src_cd
    ,p_dflt_val                      => p_dflt_val
    ,p_dflt_flag                     => p_dflt_flag
    ,p_frgn_erg_ded_typ_cd           => p_frgn_erg_ded_typ_cd
    ,p_frgn_erg_ded_name             => p_frgn_erg_ded_name
    ,p_frgn_erg_ded_ident            => p_frgn_erg_ded_ident
    ,p_no_mx_elcn_val_dfnd_flag      => p_no_mx_elcn_val_dfnd_flag
    ,p_prtl_mo_det_mthd_rl           => p_prtl_mo_det_mthd_rl
    ,p_entr_val_at_enrt_flag         => l_entr_val_at_enrt_flag
    ,p_prtl_mo_eff_dt_det_rl         => p_prtl_mo_eff_dt_det_rl
    ,p_rndg_rl                       => p_rndg_rl
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_no_mn_elcn_val_dfnd_flag      => p_no_mn_elcn_val_dfnd_flag
    ,p_prtl_mo_eff_dt_det_cd         => p_prtl_mo_eff_dt_det_cd
    ,p_only_one_bal_typ_alwd_flag    => p_only_one_bal_typ_alwd_flag
    ,p_rt_usg_cd                     => p_rt_usg_cd
    ,p_prort_mn_ann_elcn_val_cd      => p_prort_mn_ann_elcn_val_cd
    ,p_prort_mn_ann_elcn_val_rl      => p_prort_mn_ann_elcn_val_rl
    ,p_prort_mx_ann_elcn_val_cd      => p_prort_mx_ann_elcn_val_cd
    ,p_prort_mx_ann_elcn_val_rl      => p_prort_mx_ann_elcn_val_rl
    ,p_one_ann_pymt_cd               => p_one_ann_pymt_cd
    ,p_det_pl_ytd_cntrs_cd           => p_det_pl_ytd_cntrs_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_ele_rqd_flag                  => p_ele_rqd_flag
    ,p_subj_to_imptd_incm_flag       => p_subj_to_imptd_incm_flag
    ,p_element_type_id               => p_element_type_id
    ,p_input_value_id                => p_input_value_id
    ,p_input_va_calc_rl             => p_input_va_calc_rl
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_parnt_acty_base_rt_id         => p_parnt_acty_base_rt_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_opt_id                        => p_opt_id
    ,p_oiplip_id                     => p_oiplip_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_vstg_for_acty_rt_id           => p_vstg_for_acty_rt_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_TTL_COMP_LVL_FCTR_ID          => p_TTL_COMP_LVL_FCTR_ID
    ,p_COST_ALLOCATION_KEYFLEX_ID    => p_COST_ALLOCATION_KEYFLEX_ID
    ,p_ALWS_CHG_CD                   => p_ALWS_CHG_CD
    ,p_ele_entry_val_cd              => p_ele_entry_val_cd
    ,p_pay_rate_grade_rule_id        => p_pay_rate_grade_rule_id
    ,p_rate_periodization_cd              => p_rate_periodization_cd
    ,p_rate_periodization_rl              => p_rate_periodization_rl
    ,p_mn_mx_elcn_rl			=> p_mn_mx_elcn_rl
    ,p_mapping_table_name            => p_mapping_table_name
    ,p_mapping_table_pk_id	     => p_mapping_table_pk_id
    ,p_business_group_id             => p_business_group_id
    ,p_context_pgm_id                 => p_context_pgm_id
    ,p_context_pl_id                  => p_context_pl_id
    ,p_context_opt_id                 => p_context_opt_id
    ,p_element_det_rl                 => p_element_det_rl
    ,p_currency_det_cd                => p_currency_det_cd
    ,p_abr_attribute_category        => p_abr_attribute_category
    ,p_abr_attribute1                => p_abr_attribute1
    ,p_abr_attribute2                => p_abr_attribute2
    ,p_abr_attribute3                => p_abr_attribute3
    ,p_abr_attribute4                => p_abr_attribute4
    ,p_abr_attribute5                => p_abr_attribute5
    ,p_abr_attribute6                => p_abr_attribute6
    ,p_abr_attribute7                => p_abr_attribute7
    ,p_abr_attribute8                => p_abr_attribute8
    ,p_abr_attribute9                => p_abr_attribute9
    ,p_abr_attribute10               => p_abr_attribute10
    ,p_abr_attribute11               => p_abr_attribute11
    ,p_abr_attribute12               => p_abr_attribute12
    ,p_abr_attribute13               => p_abr_attribute13
    ,p_abr_attribute14               => p_abr_attribute14
    ,p_abr_attribute15               => p_abr_attribute15
    ,p_abr_attribute16               => p_abr_attribute16
    ,p_abr_attribute17               => p_abr_attribute17
    ,p_abr_attribute18               => p_abr_attribute18
    ,p_abr_attribute19               => p_abr_attribute19
    ,p_abr_attribute20               => p_abr_attribute20
    ,p_abr_attribute21               => p_abr_attribute21
    ,p_abr_attribute22               => p_abr_attribute22
    ,p_abr_attribute23               => p_abr_attribute23
    ,p_abr_attribute24               => p_abr_attribute24
    ,p_abr_attribute25               => p_abr_attribute25
    ,p_abr_attribute26               => p_abr_attribute26
    ,p_abr_attribute27               => p_abr_attribute27
    ,p_abr_attribute28               => p_abr_attribute28
    ,p_abr_attribute29               => p_abr_attribute29
    ,p_abr_attribute30               => p_abr_attribute30
    ,p_abr_seq_num                   => p_abr_seq_num
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_acty_base_rate
    --
    ben_acty_base_rate_bk1.create_acty_base_rate_a
      (
       p_acty_base_rt_id                =>  l_acty_base_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num		        =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_sub_acty_typ_cd                =>  p_sub_acty_typ_cd
      ,p_name                           =>  p_name
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_use_to_calc_net_flx_cr_flag    =>  p_use_to_calc_net_flx_cr_flag
      ,p_asn_on_enrt_flag               =>  p_asn_on_enrt_flag
      ,p_abv_mx_elcn_val_alwd_flag      =>  p_abv_mx_elcn_val_alwd_flag
      ,p_blw_mn_elcn_alwd_flag          =>  p_blw_mn_elcn_alwd_flag
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_parnt_chld_cd                  =>  p_parnt_chld_cd
      ,p_use_calc_acty_bs_rt_flag       =>  p_use_calc_acty_bs_rt_flag
      ,p_uses_ded_sched_flag            =>  p_uses_ded_sched_flag
      ,p_uses_varbl_rt_flag             =>  p_uses_varbl_rt_flag
      ,p_vstg_sched_apls_flag           =>  p_vstg_sched_apls_flag
      ,p_rt_mlt_cd                      =>  p_rt_mlt_cd
      ,p_proc_each_pp_dflt_flag         =>  p_proc_each_pp_dflt_flag
      ,p_prdct_flx_cr_when_elig_flag    =>  p_prdct_flx_cr_when_elig_flag
      ,p_no_std_rt_used_flag            =>  p_no_std_rt_used_flag
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ptd_comp_lvl_fctr_id           =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id           =>  p_clm_comp_lvl_fctr_id
      ,p_entr_ann_val_flag              =>  p_entr_ann_val_flag
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_uses_pymt_sched_flag           =>  p_uses_pymt_sched_flag
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_val                            =>  p_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_acty_base_rt_stat_cd           =>  p_acty_base_rt_stat_cd
      ,p_procg_src_cd                   =>  p_procg_src_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_frgn_erg_ded_typ_cd            =>  p_frgn_erg_ded_typ_cd
      ,p_frgn_erg_ded_name              =>  p_frgn_erg_ded_name
      ,p_frgn_erg_ded_ident             =>  p_frgn_erg_ded_ident
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_prtl_mo_eff_dt_det_rl          =>  p_prtl_mo_eff_dt_det_rl
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_prtl_mo_eff_dt_det_cd          =>  p_prtl_mo_eff_dt_det_cd
      ,p_only_one_bal_typ_alwd_flag     =>  p_only_one_bal_typ_alwd_flag
      ,p_rt_usg_cd                      =>  p_rt_usg_cd
      ,p_prort_mn_ann_elcn_val_cd       =>  p_prort_mn_ann_elcn_val_cd
      ,p_prort_mn_ann_elcn_val_rl       =>  p_prort_mn_ann_elcn_val_rl
      ,p_prort_mx_ann_elcn_val_cd       =>  p_prort_mx_ann_elcn_val_cd
      ,p_prort_mx_ann_elcn_val_rl       =>  p_prort_mx_ann_elcn_val_rl
      ,p_one_ann_pymt_cd                =>  p_one_ann_pymt_cd
      ,p_det_pl_ytd_cntrs_cd            =>  p_det_pl_ytd_cntrs_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_ele_rqd_flag                   =>  p_ele_rqd_flag
      ,p_subj_to_imptd_incm_flag        =>  p_subj_to_imptd_incm_flag
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_va_calc_rl              =>  p_input_va_calc_rl
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_vstg_for_acty_rt_id            =>  p_vstg_for_acty_rt_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_TTL_COMP_LVL_FCTR_ID           =>  p_TTL_COMP_LVL_FCTR_ID
      ,p_COST_ALLOCATION_KEYFLEX_ID     =>  p_COST_ALLOCATION_KEYFLEX_ID
      ,p_ALWS_CHG_CD                    =>  p_ALWS_CHG_CD
      ,p_ele_entry_val_cd               =>  p_ele_entry_val_cd
      ,p_pay_rate_grade_rule_id         =>  p_pay_rate_grade_rule_id
      ,p_rate_periodization_cd               => p_rate_periodization_cd
      ,p_rate_periodization_rl               => p_rate_periodization_rl
      ,p_mn_mx_elcn_rl			=> p_mn_mx_elcn_rl
      ,p_mapping_table_name		=> p_mapping_table_name
      ,p_mapping_table_pk_id		=> p_mapping_table_pk_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_context_pgm_id                 => p_context_pgm_id
      ,p_context_pl_id                  => p_context_pl_id
      ,p_context_opt_id                 => p_context_opt_id
      ,p_element_det_rl                 => p_element_det_rl
      ,p_currency_det_cd                => p_currency_det_cd
      ,p_abr_attribute_category         =>  p_abr_attribute_category
      ,p_abr_attribute1                 =>  p_abr_attribute1
      ,p_abr_attribute2                 =>  p_abr_attribute2
      ,p_abr_attribute3                 =>  p_abr_attribute3
      ,p_abr_attribute4                 =>  p_abr_attribute4
      ,p_abr_attribute5                 =>  p_abr_attribute5
      ,p_abr_attribute6                 =>  p_abr_attribute6
      ,p_abr_attribute7                 =>  p_abr_attribute7
      ,p_abr_attribute8                 =>  p_abr_attribute8
      ,p_abr_attribute9                 =>  p_abr_attribute9
      ,p_abr_attribute10                =>  p_abr_attribute10
      ,p_abr_attribute11                =>  p_abr_attribute11
      ,p_abr_attribute12                =>  p_abr_attribute12
      ,p_abr_attribute13                =>  p_abr_attribute13
      ,p_abr_attribute14                =>  p_abr_attribute14
      ,p_abr_attribute15                =>  p_abr_attribute15
      ,p_abr_attribute16                =>  p_abr_attribute16
      ,p_abr_attribute17                =>  p_abr_attribute17
      ,p_abr_attribute18                =>  p_abr_attribute18
      ,p_abr_attribute19                =>  p_abr_attribute19
      ,p_abr_attribute20                =>  p_abr_attribute20
      ,p_abr_attribute21                =>  p_abr_attribute21
      ,p_abr_attribute22                =>  p_abr_attribute22
      ,p_abr_attribute23                =>  p_abr_attribute23
      ,p_abr_attribute24                =>  p_abr_attribute24
      ,p_abr_attribute25                =>  p_abr_attribute25
      ,p_abr_attribute26                =>  p_abr_attribute26
      ,p_abr_attribute27                =>  p_abr_attribute27
      ,p_abr_attribute28                =>  p_abr_attribute28
      ,p_abr_attribute29                =>  p_abr_attribute29
      ,p_abr_attribute30                =>  p_abr_attribute30
      ,p_abr_seq_num                    => p_abr_seq_num
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_acty_base_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_acty_base_rate
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
  p_acty_base_rt_id := l_acty_base_rt_id;
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
    ROLLBACK TO create_acty_base_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_acty_base_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_acty_base_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    ROLLBACK TO create_acty_base_rate;
    raise;
    --
end create_acty_base_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< update_acty_base_rate >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_base_rate
  (p_validate                       in  boolean   default false
  ,p_acty_base_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num			    in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_sub_acty_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag    in  varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_abv_mx_elcn_val_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_blw_mn_elcn_alwd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_parnt_chld_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_use_calc_acty_bs_rt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_uses_ded_sched_flag            in  varchar2  default hr_api.g_varchar2
  ,p_uses_varbl_rt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_vstg_sched_apls_flag           in  varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_proc_each_pp_dflt_flag         in  varchar2  default hr_api.g_varchar2
  ,p_prdct_flx_cr_when_elig_flag    in  varchar2  default hr_api.g_varchar2
  ,p_no_std_rt_used_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rcrrg_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_mn_elcn_val                    in  number    default hr_api.g_number
  ,p_mx_elcn_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id           in  number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id           in  number    default hr_api.g_number
  ,p_entr_ann_val_flag              in  varchar2  default hr_api.g_varchar2
  ,p_ann_mn_elcn_val                in  number    default hr_api.g_number
  ,p_ann_mx_elcn_val                in  number    default hr_api.g_number
  ,p_wsh_rl_dy_mo_num               in  number    default hr_api.g_number
  ,p_uses_pymt_sched_flag           in  varchar2  default hr_api.g_varchar2
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_incrmt_elcn_val                in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_val_ovrid_alwd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default hr_api.g_varchar2
  ,p_acty_base_rt_stat_cd           in  varchar2  default hr_api.g_varchar2
  ,p_procg_src_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_typ_cd            in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_name              in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_ident             in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_rl            in  number    default hr_api.g_number
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_eff_dt_det_rl          in  number    default hr_api.g_number
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_eff_dt_det_cd          in  varchar2  default hr_api.g_varchar2
  ,p_only_one_bal_typ_alwd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_rt_usg_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_prort_mn_ann_elcn_val_cd       in  varchar2  default hr_api.g_varchar2
  ,p_prort_mn_ann_elcn_val_rl       in  number    default hr_api.g_number
  ,p_prort_mx_ann_elcn_val_cd       in  varchar2  default hr_api.g_varchar2
  ,p_prort_mx_ann_elcn_val_rl       in  number    default hr_api.g_number
  ,p_one_ann_pymt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_det_pl_ytd_cntrs_cd            in  varchar2  default hr_api.g_varchar2
  ,p_asmt_to_use_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ele_rqd_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_subj_to_imptd_incm_flag        in  varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_input_va_calc_rl              in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_parnt_acty_base_rt_id          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_vstg_for_acty_rt_id            in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_TTL_COMP_LVL_FCTR_ID           in  number    default hr_api.g_number
  ,p_COST_ALLOCATION_KEYFLEX_ID     in  number    default hr_api.g_number
  ,p_ALWS_CHG_CD                    in  varchar2  default hr_api.g_varchar2
  ,p_ele_entry_val_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pay_rate_grade_rule_id         in  number    default hr_api.g_number
  ,p_rate_periodization_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rate_periodization_rl               in  number    default hr_api.g_number
  ,p_mn_mx_elcn_rl		    in  number    default hr_api.g_number
  ,p_mapping_table_name		    in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id	    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_context_pgm_id                 in  number    default hr_api.g_number
  ,p_context_pl_id                  in  number    default hr_api.g_number
  ,p_context_opt_id                 in  number    default hr_api.g_number
  ,p_element_det_rl                 in  number    default hr_api.g_number
  ,p_currency_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_abr_seq_num                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_acty_base_rate';
  l_object_version_number ben_acty_base_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_base_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_base_rt_f.effective_end_date%TYPE;
  --
  l_use_to_calc_net_flx_cr_flag ben_acty_base_rt_f.use_to_calc_net_flx_cr_flag%TYPE := p_use_to_calc_net_flx_cr_flag;
  l_asn_on_enrt_flag            ben_acty_base_rt_f.asn_on_enrt_flag%TYPE            := p_asn_on_enrt_flag;
  l_entr_val_at_enrt_flag       ben_acty_base_rt_f.entr_val_at_enrt_flag%TYPE       := p_entr_val_at_enrt_flag;
  l_prdct_flx_cr_when_elig_flag ben_acty_base_rt_f.prdct_flx_cr_when_elig_flag%TYPE := p_prdct_flx_cr_when_elig_flag;
  ---
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_acty_base_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_acty_base_rate
    --
    ben_acty_base_rate_bk2.update_acty_base_rate_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_sub_acty_typ_cd                =>  p_sub_acty_typ_cd
      ,p_name                           =>  p_name
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_use_to_calc_net_flx_cr_flag    =>  p_use_to_calc_net_flx_cr_flag
      ,p_asn_on_enrt_flag               =>  p_asn_on_enrt_flag
      ,p_abv_mx_elcn_val_alwd_flag      =>  p_abv_mx_elcn_val_alwd_flag
      ,p_blw_mn_elcn_alwd_flag          =>  p_blw_mn_elcn_alwd_flag
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_parnt_chld_cd                  =>  p_parnt_chld_cd
      ,p_use_calc_acty_bs_rt_flag       =>  p_use_calc_acty_bs_rt_flag
      ,p_uses_ded_sched_flag            =>  p_uses_ded_sched_flag
      ,p_uses_varbl_rt_flag             =>  p_uses_varbl_rt_flag
      ,p_vstg_sched_apls_flag           =>  p_vstg_sched_apls_flag
      ,p_rt_mlt_cd                      =>  p_rt_mlt_cd
      ,p_proc_each_pp_dflt_flag         =>  p_proc_each_pp_dflt_flag
      ,p_prdct_flx_cr_when_elig_flag    =>  p_prdct_flx_cr_when_elig_flag
      ,p_no_std_rt_used_flag            =>  p_no_std_rt_used_flag
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ptd_comp_lvl_fctr_id           =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id           =>  p_clm_comp_lvl_fctr_id
      ,p_entr_ann_val_flag              =>  p_entr_ann_val_flag
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_uses_pymt_sched_flag           =>  p_uses_pymt_sched_flag
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_val                            =>  p_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_acty_base_rt_stat_cd           =>  p_acty_base_rt_stat_cd
      ,p_procg_src_cd                   =>  p_procg_src_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_frgn_erg_ded_typ_cd            =>  p_frgn_erg_ded_typ_cd
      ,p_frgn_erg_ded_name              =>  p_frgn_erg_ded_name
      ,p_frgn_erg_ded_ident             =>  p_frgn_erg_ded_ident
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_prtl_mo_eff_dt_det_rl          =>  p_prtl_mo_eff_dt_det_rl
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_prtl_mo_eff_dt_det_cd          =>  p_prtl_mo_eff_dt_det_cd
      ,p_only_one_bal_typ_alwd_flag     =>  p_only_one_bal_typ_alwd_flag
      ,p_rt_usg_cd                      =>  p_rt_usg_cd
      ,p_prort_mn_ann_elcn_val_cd       =>  p_prort_mn_ann_elcn_val_cd
      ,p_prort_mn_ann_elcn_val_rl       =>  p_prort_mn_ann_elcn_val_rl
      ,p_prort_mx_ann_elcn_val_cd       =>  p_prort_mx_ann_elcn_val_cd
      ,p_prort_mx_ann_elcn_val_rl       =>  p_prort_mx_ann_elcn_val_rl
      ,p_one_ann_pymt_cd                =>  p_one_ann_pymt_cd
      ,p_det_pl_ytd_cntrs_cd            =>  p_det_pl_ytd_cntrs_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_ele_rqd_flag                   =>  p_ele_rqd_flag
      ,p_subj_to_imptd_incm_flag        =>  p_subj_to_imptd_incm_flag
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_va_calc_rl              =>  p_input_va_calc_rl
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_vstg_for_acty_rt_id            =>  p_vstg_for_acty_rt_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_TTL_COMP_LVL_FCTR_ID           => p_TTL_COMP_LVL_FCTR_ID
      ,p_COST_ALLOCATION_KEYFLEX_ID     => p_COST_ALLOCATION_KEYFLEX_ID
      ,p_ALWS_CHG_CD                    => p_ALWS_CHG_CD
      ,p_ele_entry_val_cd               => p_ele_entry_val_cd
      ,p_pay_rate_grade_rule_id         => p_pay_rate_grade_rule_id
      ,p_rate_periodization_cd               => p_rate_periodization_cd
      ,p_rate_periodization_rl               => p_rate_periodization_rl
      ,p_mn_mx_elcn_rl	                => p_mn_mx_elcn_rl
      ,p_mapping_table_name             => p_mapping_table_name
      ,p_mapping_table_pk_id		=> p_mapping_table_pk_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_context_pgm_id                 => p_context_pgm_id
      ,p_context_pl_id                  => p_context_pl_id
      ,p_context_opt_id                 => p_context_opt_id
      ,p_element_det_rl                 => p_element_det_rl
      ,p_currency_det_cd                => p_currency_det_cd
      ,p_abr_attribute_category         =>  p_abr_attribute_category
      ,p_abr_attribute1                 =>  p_abr_attribute1
      ,p_abr_attribute2                 =>  p_abr_attribute2
      ,p_abr_attribute3                 =>  p_abr_attribute3
      ,p_abr_attribute4                 =>  p_abr_attribute4
      ,p_abr_attribute5                 =>  p_abr_attribute5
      ,p_abr_attribute6                 =>  p_abr_attribute6
      ,p_abr_attribute7                 =>  p_abr_attribute7
      ,p_abr_attribute8                 =>  p_abr_attribute8
      ,p_abr_attribute9                 =>  p_abr_attribute9
      ,p_abr_attribute10                =>  p_abr_attribute10
      ,p_abr_attribute11                =>  p_abr_attribute11
      ,p_abr_attribute12                =>  p_abr_attribute12
      ,p_abr_attribute13                =>  p_abr_attribute13
      ,p_abr_attribute14                =>  p_abr_attribute14
      ,p_abr_attribute15                =>  p_abr_attribute15
      ,p_abr_attribute16                =>  p_abr_attribute16
      ,p_abr_attribute17                =>  p_abr_attribute17
      ,p_abr_attribute18                =>  p_abr_attribute18
      ,p_abr_attribute19                =>  p_abr_attribute19
      ,p_abr_attribute20                =>  p_abr_attribute20
      ,p_abr_attribute21                =>  p_abr_attribute21
      ,p_abr_attribute22                =>  p_abr_attribute22
      ,p_abr_attribute23                =>  p_abr_attribute23
      ,p_abr_attribute24                =>  p_abr_attribute24
      ,p_abr_attribute25                =>  p_abr_attribute25
      ,p_abr_attribute26                =>  p_abr_attribute26
      ,p_abr_attribute27                =>  p_abr_attribute27
      ,p_abr_attribute28                =>  p_abr_attribute28
      ,p_abr_attribute29                =>  p_abr_attribute29
      ,p_abr_attribute30                =>  p_abr_attribute30
      ,p_abr_seq_num                    => p_abr_seq_num
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                      => p_effective_date
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acty_base_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_acty_base_rate
    --
  end;
  --  check the usage code if it is FLXCR then variable are changed
  If P_rt_usg_cd = 'FLXCR' then
     l_use_to_calc_net_flx_cr_flag   := 'Y' ;
     l_asn_on_enrt_flag              := 'Y' ;
     l_entr_val_at_enrt_flag         := 'N' ;
     l_prdct_flx_cr_when_elig_flag   := 'Y' ;
  end if ;
  ---
  ben_abr_upd.upd
    (
     p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num                       =>  p_ordr_num
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_sub_acty_typ_cd               => p_sub_acty_typ_cd
    ,p_name                          => p_name
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_use_to_calc_net_flx_cr_flag   => l_use_to_calc_net_flx_cr_flag
    ,p_asn_on_enrt_flag              => l_asn_on_enrt_flag
    ,p_abv_mx_elcn_val_alwd_flag     => p_abv_mx_elcn_val_alwd_flag
    ,p_blw_mn_elcn_alwd_flag         => p_blw_mn_elcn_alwd_flag
    ,p_dsply_on_enrt_flag            => p_dsply_on_enrt_flag
    ,p_parnt_chld_cd                 => p_parnt_chld_cd
    ,p_use_calc_acty_bs_rt_flag      => p_use_calc_acty_bs_rt_flag
    ,p_uses_ded_sched_flag           => p_uses_ded_sched_flag
    ,p_uses_varbl_rt_flag            => p_uses_varbl_rt_flag
    ,p_vstg_sched_apls_flag          => p_vstg_sched_apls_flag
    ,p_rt_mlt_cd                     => p_rt_mlt_cd
    ,p_proc_each_pp_dflt_flag        => p_proc_each_pp_dflt_flag
    ,p_prdct_flx_cr_when_elig_flag   => l_prdct_flx_cr_when_elig_flag
    ,p_no_std_rt_used_flag           => p_no_std_rt_used_flag
    ,p_rcrrg_cd                      => p_rcrrg_cd
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_ptd_comp_lvl_fctr_id          => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id          => p_clm_comp_lvl_fctr_id
    ,p_entr_ann_val_flag             => p_entr_ann_val_flag
    ,p_ann_mn_elcn_val               => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val               => p_ann_mx_elcn_val
    ,p_wsh_rl_dy_mo_num              => p_wsh_rl_dy_mo_num
    ,p_uses_pymt_sched_flag          => p_uses_pymt_sched_flag
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_val                           => p_val
    ,p_incrmt_elcn_val               => p_incrmt_elcn_val
    ,p_rndg_cd                       => p_rndg_cd
    ,p_val_ovrid_alwd_flag           => p_val_ovrid_alwd_flag
    ,p_prtl_mo_det_mthd_cd           => p_prtl_mo_det_mthd_cd
    ,p_acty_base_rt_stat_cd          => p_acty_base_rt_stat_cd
    ,p_procg_src_cd                  => p_procg_src_cd
    ,p_dflt_val                      => p_dflt_val
    ,p_dflt_flag                     => p_dflt_flag
    ,p_frgn_erg_ded_typ_cd           => p_frgn_erg_ded_typ_cd
    ,p_frgn_erg_ded_name             => p_frgn_erg_ded_name
    ,p_frgn_erg_ded_ident            => p_frgn_erg_ded_ident
    ,p_no_mx_elcn_val_dfnd_flag      => p_no_mx_elcn_val_dfnd_flag
    ,p_prtl_mo_det_mthd_rl           => p_prtl_mo_det_mthd_rl
    ,p_entr_val_at_enrt_flag         => l_entr_val_at_enrt_flag
    ,p_prtl_mo_eff_dt_det_rl         => p_prtl_mo_eff_dt_det_rl
    ,p_rndg_rl                       => p_rndg_rl
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_no_mn_elcn_val_dfnd_flag      => p_no_mn_elcn_val_dfnd_flag
    ,p_prtl_mo_eff_dt_det_cd         => p_prtl_mo_eff_dt_det_cd
    ,p_only_one_bal_typ_alwd_flag    => p_only_one_bal_typ_alwd_flag
    ,p_rt_usg_cd                     => p_rt_usg_cd
    ,p_prort_mn_ann_elcn_val_cd      => p_prort_mn_ann_elcn_val_cd
    ,p_prort_mn_ann_elcn_val_rl      => p_prort_mn_ann_elcn_val_rl
    ,p_prort_mx_ann_elcn_val_cd      => p_prort_mx_ann_elcn_val_cd
    ,p_prort_mx_ann_elcn_val_rl      => p_prort_mx_ann_elcn_val_rl
    ,p_one_ann_pymt_cd               => p_one_ann_pymt_cd
    ,p_det_pl_ytd_cntrs_cd           => p_det_pl_ytd_cntrs_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_ele_rqd_flag                  => p_ele_rqd_flag
    ,p_subj_to_imptd_incm_flag       => p_subj_to_imptd_incm_flag
    ,p_element_type_id               => p_element_type_id
    ,p_input_value_id                => p_input_value_id
    ,p_input_va_calc_rl             => p_input_va_calc_rl
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_parnt_acty_base_rt_id         => p_parnt_acty_base_rt_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_opt_id                        => p_opt_id
    ,p_oiplip_id                     => p_oiplip_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_vstg_for_acty_rt_id           => p_vstg_for_acty_rt_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_TTL_COMP_LVL_FCTR_ID          => p_TTL_COMP_LVL_FCTR_ID
    ,p_COST_ALLOCATION_KEYFLEX_ID    => p_COST_ALLOCATION_KEYFLEX_ID
    ,p_ALWS_CHG_CD                   => p_ALWS_CHG_CD
    ,p_ele_entry_val_cd              => p_ele_entry_val_cd
    ,p_pay_rate_grade_rule_id        => p_pay_rate_grade_rule_id
    ,p_rate_periodization_cd               => p_rate_periodization_cd
    ,p_rate_periodization_rl               => p_rate_periodization_rl
    ,p_mn_mx_elcn_rl	                => p_mn_mx_elcn_rl
    ,p_mapping_table_name            => p_mapping_table_name
    ,p_mapping_table_pk_id           => p_mapping_table_pk_id
    ,p_business_group_id             => p_business_group_id
    ,p_context_pgm_id                 => p_context_pgm_id
    ,p_context_pl_id                  => p_context_pl_id
    ,p_context_opt_id                 => p_context_opt_id
    ,p_element_det_rl                 => p_element_det_rl
    ,p_currency_det_cd                => p_currency_det_cd
    ,p_abr_attribute_category        => p_abr_attribute_category
    ,p_abr_attribute1                => p_abr_attribute1
    ,p_abr_attribute2                => p_abr_attribute2
    ,p_abr_attribute3                => p_abr_attribute3
    ,p_abr_attribute4                => p_abr_attribute4
    ,p_abr_attribute5                => p_abr_attribute5
    ,p_abr_attribute6                => p_abr_attribute6
    ,p_abr_attribute7                => p_abr_attribute7
    ,p_abr_attribute8                => p_abr_attribute8
    ,p_abr_attribute9                => p_abr_attribute9
    ,p_abr_attribute10               => p_abr_attribute10
    ,p_abr_attribute11               => p_abr_attribute11
    ,p_abr_attribute12               => p_abr_attribute12
    ,p_abr_attribute13               => p_abr_attribute13
    ,p_abr_attribute14               => p_abr_attribute14
    ,p_abr_attribute15               => p_abr_attribute15
    ,p_abr_attribute16               => p_abr_attribute16
    ,p_abr_attribute17               => p_abr_attribute17
    ,p_abr_attribute18               => p_abr_attribute18
    ,p_abr_attribute19               => p_abr_attribute19
    ,p_abr_attribute20               => p_abr_attribute20
    ,p_abr_attribute21               => p_abr_attribute21
    ,p_abr_attribute22               => p_abr_attribute22
    ,p_abr_attribute23               => p_abr_attribute23
    ,p_abr_attribute24               => p_abr_attribute24
    ,p_abr_attribute25               => p_abr_attribute25
    ,p_abr_attribute26               => p_abr_attribute26
    ,p_abr_attribute27               => p_abr_attribute27
    ,p_abr_attribute28               => p_abr_attribute28
    ,p_abr_attribute29               => p_abr_attribute29
    ,p_abr_attribute30               => p_abr_attribute30
    ,p_abr_seq_num                   => p_abr_seq_num
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_acty_base_rate
    --
    ben_acty_base_rate_bk2.update_acty_base_rate_a
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_sub_acty_typ_cd                =>  p_sub_acty_typ_cd
      ,p_name                           =>  p_name
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_use_to_calc_net_flx_cr_flag    =>  p_use_to_calc_net_flx_cr_flag
      ,p_asn_on_enrt_flag               =>  p_asn_on_enrt_flag
      ,p_abv_mx_elcn_val_alwd_flag      =>  p_abv_mx_elcn_val_alwd_flag
      ,p_blw_mn_elcn_alwd_flag          =>  p_blw_mn_elcn_alwd_flag
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_parnt_chld_cd                  =>  p_parnt_chld_cd
      ,p_use_calc_acty_bs_rt_flag       =>  p_use_calc_acty_bs_rt_flag
      ,p_uses_ded_sched_flag            =>  p_uses_ded_sched_flag
      ,p_uses_varbl_rt_flag             =>  p_uses_varbl_rt_flag
      ,p_vstg_sched_apls_flag           =>  p_vstg_sched_apls_flag
      ,p_rt_mlt_cd                      =>  p_rt_mlt_cd
      ,p_proc_each_pp_dflt_flag         =>  p_proc_each_pp_dflt_flag
      ,p_prdct_flx_cr_when_elig_flag    =>  p_prdct_flx_cr_when_elig_flag
      ,p_no_std_rt_used_flag            =>  p_no_std_rt_used_flag
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ptd_comp_lvl_fctr_id           =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id           =>  p_clm_comp_lvl_fctr_id
      ,p_entr_ann_val_flag              =>  p_entr_ann_val_flag
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_uses_pymt_sched_flag           =>  p_uses_pymt_sched_flag
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_val                            =>  p_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_acty_base_rt_stat_cd           =>  p_acty_base_rt_stat_cd
      ,p_procg_src_cd                   =>  p_procg_src_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_frgn_erg_ded_typ_cd            =>  p_frgn_erg_ded_typ_cd
      ,p_frgn_erg_ded_name              =>  p_frgn_erg_ded_name
      ,p_frgn_erg_ded_ident             =>  p_frgn_erg_ded_ident
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_prtl_mo_eff_dt_det_rl          =>  p_prtl_mo_eff_dt_det_rl
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_prtl_mo_eff_dt_det_cd          =>  p_prtl_mo_eff_dt_det_cd
      ,p_only_one_bal_typ_alwd_flag     =>  p_only_one_bal_typ_alwd_flag
      ,p_rt_usg_cd                      =>  p_rt_usg_cd
      ,p_prort_mn_ann_elcn_val_cd       =>  p_prort_mn_ann_elcn_val_cd
      ,p_prort_mn_ann_elcn_val_rl       =>  p_prort_mn_ann_elcn_val_rl
      ,p_prort_mx_ann_elcn_val_cd       =>  p_prort_mx_ann_elcn_val_cd
      ,p_prort_mx_ann_elcn_val_rl       =>  p_prort_mx_ann_elcn_val_rl
      ,p_one_ann_pymt_cd                =>  p_one_ann_pymt_cd
      ,p_det_pl_ytd_cntrs_cd            =>  p_det_pl_ytd_cntrs_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_ele_rqd_flag                   =>  p_ele_rqd_flag
      ,p_subj_to_imptd_incm_flag        =>  p_subj_to_imptd_incm_flag
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_va_calc_rl               =>  p_input_va_calc_rl
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_opt_id                         =>  p_opt_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_vstg_for_acty_rt_id            =>  p_vstg_for_acty_rt_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_TTL_COMP_LVL_FCTR_ID           => p_TTL_COMP_LVL_FCTR_ID
      ,p_COST_ALLOCATION_KEYFLEX_ID     => p_COST_ALLOCATION_KEYFLEX_ID
      ,p_ALWS_CHG_CD                    => p_ALWS_CHG_CD
      ,p_ele_entry_val_cd               => p_ele_entry_val_cd
      ,p_pay_rate_grade_rule_id          => p_pay_rate_grade_rule_id
      ,p_rate_periodization_cd          => p_rate_periodization_cd
      ,p_rate_periodization_rl          => p_rate_periodization_rl
      ,p_mn_mx_elcn_rl	                => p_mn_mx_elcn_rl
      ,p_mapping_table_name		=> p_mapping_table_pk_id
      ,p_mapping_table_pk_id            => p_mapping_table_pk_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_context_pgm_id                 => p_context_pgm_id
      ,p_context_pl_id                  => p_context_pl_id
      ,p_context_opt_id                 => p_context_opt_id
      ,p_element_det_rl                 => p_element_det_rl
      ,p_currency_det_cd                => p_currency_det_cd
      ,p_abr_attribute_category         =>  p_abr_attribute_category
      ,p_abr_attribute1                 =>  p_abr_attribute1
      ,p_abr_attribute2                 =>  p_abr_attribute2
      ,p_abr_attribute3                 =>  p_abr_attribute3
      ,p_abr_attribute4                 =>  p_abr_attribute4
      ,p_abr_attribute5                 =>  p_abr_attribute5
      ,p_abr_attribute6                 =>  p_abr_attribute6
      ,p_abr_attribute7                 =>  p_abr_attribute7
      ,p_abr_attribute8                 =>  p_abr_attribute8
      ,p_abr_attribute9                 =>  p_abr_attribute9
      ,p_abr_attribute10                =>  p_abr_attribute10
      ,p_abr_attribute11                =>  p_abr_attribute11
      ,p_abr_attribute12                =>  p_abr_attribute12
      ,p_abr_attribute13                =>  p_abr_attribute13
      ,p_abr_attribute14                =>  p_abr_attribute14
      ,p_abr_attribute15                =>  p_abr_attribute15
      ,p_abr_attribute16                =>  p_abr_attribute16
      ,p_abr_attribute17                =>  p_abr_attribute17
      ,p_abr_attribute18                =>  p_abr_attribute18
      ,p_abr_attribute19                =>  p_abr_attribute19
      ,p_abr_attribute20                =>  p_abr_attribute20
      ,p_abr_attribute21                =>  p_abr_attribute21
      ,p_abr_attribute22                =>  p_abr_attribute22
      ,p_abr_attribute23                =>  p_abr_attribute23
      ,p_abr_attribute24                =>  p_abr_attribute24
      ,p_abr_attribute25                =>  p_abr_attribute25
      ,p_abr_attribute26                =>  p_abr_attribute26
      ,p_abr_attribute27                =>  p_abr_attribute27
      ,p_abr_attribute28                =>  p_abr_attribute28
      ,p_abr_attribute29                =>  p_abr_attribute29
      ,p_abr_attribute30                =>  p_abr_attribute30
      ,p_abr_seq_num                    => p_abr_seq_num
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acty_base_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_acty_base_rate
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
    ROLLBACK TO update_acty_base_rate;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    ROLLBACK TO update_acty_base_rate;
    raise;
    --
end update_acty_base_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_acty_base_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_base_rate
  (p_validate                       in  boolean  default false
  ,p_acty_base_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_acty_base_rate';
  l_object_version_number ben_acty_base_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_base_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_base_rt_f.effective_end_date%TYPE;
  l_dummy     varchar2(1);
  l_error boolean;
  --
  cursor c_chk_ecr is
  select 'x'
    from ben_enrt_rt ecr,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
   where ecr.acty_base_rt_id = p_acty_base_rt_id
     and epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
     and pil.per_in_ler_id = epe.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  union
  select 'x'
    from ben_enrt_rt ecr,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
   where ecr.acty_base_rt_id = p_acty_base_rt_id
     and enb.enrt_bnft_id = ecr.enrt_bnft_id
     and epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and pil.per_in_ler_id = epe.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  cursor c_chk_prv is
  select 'x'
    from ben_prtt_rt_val
   where acty_base_rt_id = p_acty_base_rt_id
     and prtt_rt_val_stat_cd is null;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_acty_base_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Bug 3636162, Following If condition added so as to avoid the check for records
  -- in ben_prtt_rt, ben_enrt_rt tables for delete modes FUTURE_CHANGE, DELETE_NEXT_CHANGE.
  --
 if p_datetrack_mode not in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
    open c_chk_ecr;
    fetch c_chk_ecr into l_dummy;
    l_error := c_chk_ecr%found;
    close c_chk_ecr;
    --
    if not l_error then
       open c_chk_prv;
       fetch c_chk_prv into l_dummy;
       l_error := c_chk_prv%found;
       close c_chk_prv;
    end if;
  --
  if l_error then
     fnd_message.set_name('BEN','BEN_93678_CANNOT_DEL_ABR');
     fnd_message.raise_error;
  end if;
  --
 End If;
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_acty_base_rate
    --
    ben_acty_base_rate_bk3.delete_acty_base_rate_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => p_effective_date
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acty_base_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_acty_base_rate
    --
  end;
  --
  ben_abr_del.del
    (
     p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_acty_base_rate
    --
    ben_acty_base_rate_bk3.delete_acty_base_rate_a
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => p_effective_date
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acty_base_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_acty_base_rate
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
    ROLLBACK TO delete_acty_base_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- uncommented for the nocopy
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    --
    ROLLBACK TO delete_acty_base_rate;
    raise;
    --
end delete_acty_base_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_acty_base_rt_id                   in     number
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
  ben_abr_shd.lck
    (
      p_acty_base_rt_id                 => p_acty_base_rt_id
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
end ben_acty_base_rate_api;

/
