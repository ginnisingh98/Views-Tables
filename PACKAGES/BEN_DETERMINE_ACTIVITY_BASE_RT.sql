--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ACTIVITY_BASE_RT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ACTIVITY_BASE_RT" AUTHID CURRENT_USER as
/* $Header: benactbr.pkh 120.2.12010000.1 2008/07/29 12:02:39 appldev ship $ */
--------------------------------------------------------------------------------
--                           main
--------------------------------------------------------------------------------
PROCEDURE main
  (p_currepe_row                 in ben_determine_rates.g_curr_epe_rec
   := ben_determine_rates.g_def_curr_epe_rec
  ,p_per_row                     in per_all_people_F%rowtype
   := ben_determine_rates.g_def_curr_per_rec
  ,p_asg_row                     in per_all_assignments_f%rowtype
   := ben_determine_rates.g_def_curr_asg_rec
  ,p_ast_row                     in per_assignment_status_types%rowtype
   := ben_determine_rates.g_def_curr_ast_rec
  ,p_adr_row                     in per_addresses%rowtype
   := ben_determine_rates.g_def_curr_adr_rec
  ,p_person_id                   IN number
  ,p_elig_per_elctbl_chc_id      IN number
  ,p_enrt_bnft_id                IN number default null
  ,p_acty_base_rt_id             IN number
  ,p_effective_date              IN date
  ,p_lf_evt_ocrd_dt              IN date default null
  ,p_perform_rounding_flg        IN boolean default true
  ,p_calc_only_rt_val_flag       in boolean default false
  ,p_pl_id                       in number  default null
  ,p_oipl_id                     in number  default null
  ,p_pgm_id                      in number  default null
  ,p_pl_typ_id                   in number  default null
  ,p_per_in_ler_id               in number  default null
  ,p_ler_id                      in number  default null
  ,p_bnft_amt                    in number  default null
  ,p_business_group_id           in number  default null
  ,p_cal_val                     in number  default null
  ,p_parent_val                  in number  default null
  ,p_called_from_ss              in boolean default false --6314463
  ,p_val                         OUT NOCOPY number
  ,p_mn_elcn_val                 OUT NOCOPY number
  ,p_mx_elcn_val                 OUT NOCOPY number
  ,p_ann_val                     OUT NOCOPY number
  ,p_ann_mn_elcn_val             OUT NOCOPY number
  ,p_ann_mx_elcn_val             OUT NOCOPY number
  ,p_cmcd_val                    OUT NOCOPY number
  ,p_cmcd_mn_elcn_val            OUT NOCOPY number
  ,p_cmcd_mx_elcn_val            OUT NOCOPY number
  ,p_cmcd_acty_ref_perd_cd       OUT NOCOPY varchar2
  ,p_incrmt_elcn_val             OUT NOCOPY number
  ,p_dflt_val                    OUT NOCOPY number
  ,p_tx_typ_cd                   OUT NOCOPY varchar2
  ,p_acty_typ_cd                 OUT NOCOPY varchar2
  ,p_nnmntry_uom                 OUT NOCOPY varchar2
  ,p_entr_val_at_enrt_flag       OUT NOCOPY varchar2
  ,p_dsply_on_enrt_flag          OUT NOCOPY varchar2
  ,p_use_to_calc_net_flx_cr_flag OUT NOCOPY varchar2
  ,p_rt_usg_cd                   OUT NOCOPY varchar2
  ,p_bnft_prvdr_pool_id          OUT NOCOPY number
  ,p_actl_prem_id                OUT NOCOPY number
  ,p_cvg_calc_amt_mthd_id        OUT NOCOPY number
  ,p_bnft_rt_typ_cd              OUT NOCOPY varchar2
  ,p_rt_typ_cd                   OUT NOCOPY varchar2
  ,p_rt_mlt_cd                   OUT NOCOPY varchar2
  ,p_comp_lvl_fctr_id            OUT NOCOPY number
  ,p_entr_ann_val_flag           OUT NOCOPY varchar2
  ,p_ptd_comp_lvl_fctr_id        OUT NOCOPY number
  ,p_clm_comp_lvl_fctr_id        OUT NOCOPY number
  ,p_ann_dflt_val                OUT NOCOPY number
  ,p_rt_strt_dt                  OUT NOCOPY date
  ,p_rt_strt_dt_cd               OUT NOCOPY varchar2
  ,p_rt_strt_dt_rl               OUT NOCOPY number
  ,p_prtt_rt_val_id              OUT NOCOPY number
  ,p_dsply_mn_elcn_val           OUT NOCOPY number
  ,p_dsply_mx_elcn_val           OUT NOCOPY number
  ,p_pp_in_yr_used_num           OUT NOCOPY number
  ,p_ordr_num           	 OUT NOCOPY number
  ,p_iss_val             	 OUT NOCOPY number
  );

--------------------------------------------------------------------------------
--                                 main_w
--------------------------------------------------------------------------------
PROCEDURE main_w
  (p_person_id                   IN number
  ,p_elig_per_elctbl_chc_id      IN number
  ,p_enrt_bnft_id                IN number default null
  ,p_acty_base_rt_id             IN number
  ,p_effective_date              IN date
  ,p_lf_evt_ocrd_dt              IN date   default null
  ,p_calc_only_rt_val_flag       in varchar2 default 'N'
  ,p_pl_id                       in number default null
  ,p_oipl_id                     in number default null
  ,p_pgm_id                      in number default null
  ,p_pl_typ_id                   in number default null
  ,p_per_in_ler_id               in number default null
  ,p_ler_id                      in number default null
  ,p_bnft_amt                    in number default null
  ,p_business_group_id           in number default null
  ,p_val                         OUT NOCOPY number
  ,p_ann_val                     OUT NOCOPY number
  ,p_cmcd_val                    OUT NOCOPY number);
 --
l_icd_chc_rates_tab        ben_icm_life_events.icd_chc_rates_tab;
 --
end ben_determine_activity_base_rt;

/
