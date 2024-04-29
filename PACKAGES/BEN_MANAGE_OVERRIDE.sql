--------------------------------------------------------
--  DDL for Package BEN_MANAGE_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_OVERRIDE" AUTHID CURRENT_USER as
/* $Header: benovrrd.pkh 120.0 2005/05/28 09:12:05 appldev noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      16-Apr-02	ikasire    Created.
  115.1      20-May-02  ikasire    GSCC Warnings fixed
  115.2      06-Dec-02  tjesumic   nocopy
  115.3      08-Apr-03  ikasire    Bug 2852325 New procedures for end dating the
                                   Rates and Dependents when coverage is ended
                                   and reopen_rate_and_dependents .
  115.4      16-Apr-03  ikasire    Bug 2859290 added Premium routine
  115.5      05-Sep-04  ikasire    FIDOML- Override Enhancements
  -----------------------------------------------------------------------------
*/
--
procedure create_electable_choices
  (p_called_from_key_listval in varchar2 default 'N'
  ,p_person_id               in number
  ,p_per_in_ler_id           in number
  ,p_run_mode                in varchar2 default 'V'
  ,p_business_group_id       in number
  ,p_effective_date          in date
  ,p_lf_evt_ocrd_dt          in date
  ,p_ler_id                  in number
  ,p_pl_id                   in number
  ,p_pgm_id                  in number default null
  ,p_oipl_id                 in number default null
  ,p_ptip_id                 in number default null
  ,p_plip_id                 in number default null
  ,p_create_anyhow_flag      in varchar2 default 'N'
  ,p_asnd_lf_evt_dt          in date default null
  ,p_electable_flag         out nocopy varchar2
  ,p_elig_per_elctbl_chc_id out nocopy number
  ,p_enrt_cvg_strt_dt       out nocopy date
  ,p_enrt_bnft_id           out nocopy number
  ,p_bnft_amt               out nocopy number
  ,p_bnft_typ_cd            out nocopy varchar2
  ,p_bnft_nnmntry_uom       out nocopy varchar2
  );
procedure post_override
  (p_elig_per_elctbl_chc_id     in number
  ,p_prtt_enrt_rslt_id          in number
  ,p_effective_date             in date
  -- for manage enrt_bnft
  ,p_enrt_bnft_id               in number default null
  ,p_business_group_id          in number
  );
-- Wrapper for update_elig_dependents call
procedure update_elig_dpnt
  (p_elig_dpnt_id           in number
  ,p_elig_cvrd_dpnt_id      in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ,p_object_version_number  in out nocopy number
  );
-- Procedure end dating the rates and coverages when result is end dated.
procedure end_rate_and_dependents
  (p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_enrt_cvg_thru_dt       in date
  ,p_effective_date         in date
  );
--
-- Procedure to reopen the rates and coverages when result is end dated.
--
procedure reopen_rate_and_dependents
  (p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_effective_date         in date
  );
--
-- Procedure to add participant premium calculations
--
procedure override_prtt_prem
  (p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number
  ,p_oipl_id                in number default null
  ,p_enrt_bnft_id           in number default null
  ,p_prtt_enrt_rslt_id      in number
  ,p_elig_per_elctbl_chc_id in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date
  );
--
procedure correct_prtt_enrt_rslt
  (p_prtt_enrt_rslt_id      in number
  ,p_enrt_cvg_strt_dt       in date     default hr_api.g_date
  ,p_enrt_cvg_thru_dt       in date     default hr_api.g_date
  ,p_bnft_amt               in number   default hr_api.g_number
  ,p_enrt_ovridn_flag       in varchar2 default hr_api.g_varchar2
  ,p_enrt_ovrid_thru_dt     in date     default hr_api.g_date
  ,p_enrt_ovrid_rsn_cd      in varchar2 default hr_api.g_varchar2
  ,p_orgnl_enrt_dt          in date     default hr_api.g_date
  ,p_effective_date         in date
  );
--
procedure override_debit_ledger_entry
  (p_validate                 in boolean default false
  ,p_calculate_only_mode      in boolean default false
  ,p_person_id                in number
  ,p_per_in_ler_id            in number
  ,p_elig_per_elctbl_chc_id   in number
  ,p_prtt_enrt_rslt_id        in number
  ,p_decr_bnft_prvdr_pool_id  in number
  ,p_acty_base_rt_id          in number
  ,p_prtt_rt_val_id           in number
  ,p_enrt_mthd_cd             in varchar2
  ,p_val                      in number
  ,p_bnft_prvdd_ldgr_id       in out nocopy number
  ,p_business_group_id        in number
  ,p_effective_date           in date
  --
  ,p_bpl_used_val             out nocopy number
  );
--
procedure override_prtt_rt_val
  (
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_id                 in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_enrt_rt_id                     in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_rt_end_dt                      in  date      default hr_api.g_date
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num			    in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rt_val                         in  number    default hr_api.g_number
  ,p_ann_rt_val                     in  number    default hr_api.g_number
  ,p_cmcd_rt_val                    in  number    default hr_api.g_number
  ,p_cmcd_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_thru_dt              in  date      default hr_api.g_date
  ,p_elctns_made_dt                 in  date      default hr_api.g_date
  ,p_prtt_rt_val_stat_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_element_entry_value_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ended_per_in_ler_id            in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default hr_api.g_number
  ,p_pp_in_yr_used_num              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_pk_id_table_name               in  varchar2  default hr_api.g_varchar2
  ,p_pk_id                          in  number    default hr_api.g_number
  ,p_no_end_element                 in  boolean   default false
  ,p_old_rt_strt_dt                 in  date      default hr_api.g_date
  ,p_old_rt_end_dt                  in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
procedure override_certifications
    (p_prtt_enrt_rslt_id      in number
    ,p_ctfn_rqd_flag          in varchar2 default hr_api.g_varchar2
    ,p_effective_date         in date
    ,p_business_group_id      in number
    );
--
procedure rollback_choices ;
--
END ben_manage_override;

 

/
