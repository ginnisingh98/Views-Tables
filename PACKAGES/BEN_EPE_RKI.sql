--------------------------------------------------------
--  DDL for Package BEN_EPE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPE_RKI" AUTHID CURRENT_USER as
/* $Header: beeperhi.pkh 120.0 2005/05/28 02:37:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_per_elctbl_chc_id         in number
-- ,p_enrt_typ_cycl_cd               in varchar2
 ,p_enrt_cvg_strt_dt_cd            in varchar2
-- ,p_enrt_perd_end_dt               in date
-- ,p_enrt_perd_strt_dt              in date
 ,p_enrt_cvg_strt_dt_rl            in varchar2
-- ,p_rt_strt_dt                     in date
-- ,p_rt_strt_dt_rl                  in varchar2
-- ,p_rt_strt_dt_cd                  in varchar2
 ,p_ctfn_rqd_flag                  in varchar2
 ,p_pil_elctbl_chc_popl_id         in number
 ,p_roll_crs_flag                  in varchar2
 ,p_crntly_enrd_flag               in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_elctbl_flag                    in varchar2
 ,p_mndtry_flag                    in varchar2
 ,p_in_pndg_wkflow_flag            in varchar2
-- ,p_dflt_enrt_dt                   in date
 ,p_dpnt_cvg_strt_dt_cd            in varchar2
 ,p_dpnt_cvg_strt_dt_rl            in varchar2
 ,p_enrt_cvg_strt_dt               in date
 ,p_alws_dpnt_dsgn_flag            in varchar2
 ,p_dpnt_dsgn_cd                   in varchar2
 ,p_ler_chg_dpnt_cvg_cd            in varchar2
 ,p_erlst_deenrt_dt                in date
 ,p_procg_end_dt                   in date
 ,p_comp_lvl_cd                    in varchar2
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_pgm_id                         in number
 ,p_plip_id                        in number
 ,p_ptip_id                        in number
 ,p_pl_typ_id                      in number
 ,p_oiplip_id                      in number
 ,p_cmbn_plip_id                   in number
 ,p_cmbn_ptip_id                   in number
 ,p_cmbn_ptip_opt_id               in number
 ,p_assignment_id                  in number
 ,p_spcl_rt_pl_id                  in number
 ,p_spcl_rt_oipl_id                in number
 ,p_must_enrl_anthr_pl_id          in number
 ,p_int_elig_per_elctbl_chc_id          in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_bnft_prvdr_pool_id             in number
 ,p_per_in_ler_id                  in number
 ,p_yr_perd_id                     in number
 ,p_auto_enrt_flag                 in varchar2
 ,p_business_group_id              in number
 ,p_pl_ordr_num                   in number
 ,p_plip_ordr_num                 in number
 ,p_ptip_ordr_num                 in number
 ,p_oipl_ordr_num                 in number
 -- cwb
 ,p_comments                        in  varchar2
 ,p_elig_flag                       in  varchar2
 ,p_elig_ovrid_dt                   in  date
 ,p_elig_ovrid_person_id            in  number
 ,p_inelig_rsn_cd                   in  varchar2
 ,p_mgr_ovrid_dt                    in  date
 ,p_mgr_ovrid_person_id             in  number
 ,p_ws_mgr_id                       in  number
 -- cwb
 ,p_epe_attribute_category         in varchar2
 ,p_epe_attribute1                 in varchar2
 ,p_epe_attribute2                 in varchar2
 ,p_epe_attribute3                 in varchar2
 ,p_epe_attribute4                 in varchar2
 ,p_epe_attribute5                 in varchar2
 ,p_epe_attribute6                 in varchar2
 ,p_epe_attribute7                 in varchar2
 ,p_epe_attribute8                 in varchar2
 ,p_epe_attribute9                 in varchar2
 ,p_epe_attribute10                in varchar2
 ,p_epe_attribute11                in varchar2
 ,p_epe_attribute12                in varchar2
 ,p_epe_attribute13                in varchar2
 ,p_epe_attribute14                in varchar2
 ,p_epe_attribute15                in varchar2
 ,p_epe_attribute16                in varchar2
 ,p_epe_attribute17                in varchar2
 ,p_epe_attribute18                in varchar2
 ,p_epe_attribute19                in varchar2
 ,p_epe_attribute20                in varchar2
 ,p_epe_attribute21                in varchar2
 ,p_epe_attribute22                in varchar2
 ,p_epe_attribute23                in varchar2
 ,p_epe_attribute24                in varchar2
 ,p_epe_attribute25                in varchar2
 ,p_epe_attribute26                in varchar2
 ,p_epe_attribute27                in varchar2
 ,p_epe_attribute28                in varchar2
 ,p_epe_attribute29                in varchar2
 ,p_epe_attribute30                in varchar2
 ,p_approval_status_cd             in varchar2
 ,p_fonm_cvg_strt_dt               in date
 ,p_cryfwd_elig_dpnt_cd            in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_epe_rki;

 

/
