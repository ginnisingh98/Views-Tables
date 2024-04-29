--------------------------------------------------------
--  DDL for Package BEN_ELIG_PER_ELC_CHC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PER_ELC_CHC_API" AUTHID CURRENT_USER as
/* $Header: beepeapi.pkh 120.0 2005/05/28 02:36:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_PER_ELC_CHC >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_perd_end_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_enrt_cvg_strt_dt_rl          No   varchar2
--   p_rt_strt_dt                   No   date
--   p_rt_strt_dt_rl                No   varchar2
--   p_rt_strt_dt_cd                No   varchar2
--   p_roll_crs_flag           No   varchar2
--   p_crntly_enrd_flag             Yes  varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_elctbl_flag                  Yes  varchar2
--   p_mndtry_flag                  Yes  varchar2
--   p_in_pndg_wkflow_flag          No   varchar2
--   p_dflt_enrt_dt                 No   date
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   varchar2
--   p_enrt_cvg_strt_dt             No   date
--   p_alws_dpnt_dsgn_flag          Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_ler_chg_dpnt_cvg_cd          No   varchar2
--   p_erlst_deenrt_dt              No   date
--   p_procg_end_dt                 No   date
--   p_comp_lvl_cd                  No   varchar2
--   p_pl_id                        Yes  number
--   p_oipl_id                      No   number
--   p_pgm_id                       No   number
--   p_pgm_typ_cd                   No   varchar2
--   p_plip_id                      No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_oiplip_id                    No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_assignment_id                No   number
--   p_spcl_rt_pl_id                Yes  number
--   p_spcl_rt_oipl_id              Yes  number
--   p_must_enrl_anthr_pl_id        Yes  number
--   p_int_elig_per_elctbl_chc_id   Yes  number
--   p_prtt_enrt_rslt_id            No   number
--   p_bnft_prvdr_pool_id           Yes  number
--   p_per_in_ler_id                Yes  number
--   p_yr_perd_id                   No   number
--   p_auto_enrt_flag               No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_epe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_epe_attribute1               No   varchar2  Descriptive Flexfield
--   p_epe_attribute2               No   varchar2  Descriptive Flexfield
--   p_epe_attribute3               No   varchar2  Descriptive Flexfield
--   p_epe_attribute4               No   varchar2  Descriptive Flexfield
--   p_epe_attribute5               No   varchar2  Descriptive Flexfield
--   p_epe_attribute6               No   varchar2  Descriptive Flexfield
--   p_epe_attribute7               No   varchar2  Descriptive Flexfield
--   p_epe_attribute8               No   varchar2  Descriptive Flexfield
--   p_epe_attribute9               No   varchar2  Descriptive Flexfield
--   p_epe_attribute10              No   varchar2  Descriptive Flexfield
--   p_epe_attribute11              No   varchar2  Descriptive Flexfield
--   p_epe_attribute12              No   varchar2  Descriptive Flexfield
--   p_epe_attribute13              No   varchar2  Descriptive Flexfield
--   p_epe_attribute14              No   varchar2  Descriptive Flexfield
--   p_epe_attribute15              No   varchar2  Descriptive Flexfield
--   p_epe_attribute16              No   varchar2  Descriptive Flexfield
--   p_epe_attribute17              No   varchar2  Descriptive Flexfield
--   p_epe_attribute18              No   varchar2  Descriptive Flexfield
--   p_epe_attribute19              No   varchar2  Descriptive Flexfield
--   p_epe_attribute20              No   varchar2  Descriptive Flexfield
--   p_epe_attribute21              No   varchar2  Descriptive Flexfield
--   p_epe_attribute22              No   varchar2  Descriptive Flexfield
--   p_epe_attribute23              No   varchar2  Descriptive Flexfield
--   p_epe_attribute24              No   varchar2  Descriptive Flexfield
--   p_epe_attribute25              No   varchar2  Descriptive Flexfield
--   p_epe_attribute26              No   varchar2  Descriptive Flexfield
--   p_epe_attribute27              No   varchar2  Descriptive Flexfield
--   p_epe_attribute28              No   varchar2  Descriptive Flexfield
--   p_epe_attribute29              No   varchar2  Descriptive Flexfield
--   p_epe_attribute30              No   varchar2  Descriptive Flexfield
--   p_approval_status_cd           No   varchar2
--   p_cryfwd_elig_dpnt_cd          No   varchar2
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_elig_per_elctbl_chc_id       Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ELIG_PER_ELC_CHC
(
   p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         out nocopy number
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default null
--  ,p_rt_strt_dt                     in  date      default null
--  ,p_rt_strt_dt_rl                  in  varchar2  default null
--  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_ctfn_rqd_flag                  in varchar2   default 'N'
  ,p_pil_elctbl_chc_popl_id         in number     default null
  ,p_roll_crs_flag                  in  varchar2  default 'N'
  ,p_crntly_enrd_flag               in  varchar2  default 'N'
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_elctbl_flag                    in  varchar2  default 'N'
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_in_pndg_wkflow_flag            in  varchar2  default 'N'
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_spcl_rt_pl_id                  in  number    default null
  ,p_spcl_rt_oipl_id                in  number    default null
  ,p_must_enrl_anthr_pl_id          in  number    default null
  ,p_int_elig_per_elctbl_chc_id          in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                    in  number    default null
  ,p_ptip_ordr_num                    in  number    default null
  ,p_oipl_ordr_num                    in  number    default null
  -- cwb
  ,p_comments                        in  varchar2   default null
  ,p_elig_flag                       in  varchar2   default 'Y'
  ,p_elig_ovrid_dt                   in  date       default null
  ,p_elig_ovrid_person_id            in  number     default null
  ,p_inelig_rsn_cd                   in  varchar2   default null
  ,p_mgr_ovrid_dt                    in  date       default null
  ,p_mgr_ovrid_person_id             in  number     default null
  ,p_ws_mgr_id                       in  number     default null
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default null
  ,p_epe_attribute1                 in  varchar2  default null
  ,p_epe_attribute2                 in  varchar2  default null
  ,p_epe_attribute3                 in  varchar2  default null
  ,p_epe_attribute4                 in  varchar2  default null
  ,p_epe_attribute5                 in  varchar2  default null
  ,p_epe_attribute6                 in  varchar2  default null
  ,p_epe_attribute7                 in  varchar2  default null
  ,p_epe_attribute8                 in  varchar2  default null
  ,p_epe_attribute9                 in  varchar2  default null
  ,p_epe_attribute10                in  varchar2  default null
  ,p_epe_attribute11                in  varchar2  default null
  ,p_epe_attribute12                in  varchar2  default null
  ,p_epe_attribute13                in  varchar2  default null
  ,p_epe_attribute14                in  varchar2  default null
  ,p_epe_attribute15                in  varchar2  default null
  ,p_epe_attribute16                in  varchar2  default null
  ,p_epe_attribute17                in  varchar2  default null
  ,p_epe_attribute18                in  varchar2  default null
  ,p_epe_attribute19                in  varchar2  default null
  ,p_epe_attribute20                in  varchar2  default null
  ,p_epe_attribute21                in  varchar2  default null
  ,p_epe_attribute22                in  varchar2  default null
  ,p_epe_attribute23                in  varchar2  default null
  ,p_epe_attribute24                in  varchar2  default null
  ,p_epe_attribute25                in  varchar2  default null
  ,p_epe_attribute26                in  varchar2  default null
  ,p_epe_attribute27                in  varchar2  default null
  ,p_epe_attribute28                in  varchar2  default null
  ,p_epe_attribute29                in  varchar2  default null
  ,p_epe_attribute30                in  varchar2  default null
  ,p_approval_status_cd             in  varchar2  default null
  ,p_fonm_cvg_strt_dt               in  date      default null
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
 );
--
-- Performance cover
--
procedure create_perf_ELIG_PER_ELC_CHC
  (p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         out nocopy number
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_ctfn_rqd_flag                  in varchar2   default 'N'
  ,p_pil_elctbl_chc_popl_id         in number     default null
  ,p_roll_crs_flag                  in  varchar2  default 'N'
  ,p_crntly_enrd_flag               in  varchar2  default 'N'
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_elctbl_flag                    in  varchar2  default 'N'
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_in_pndg_wkflow_flag            in  varchar2  default 'N'
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_spcl_rt_pl_id                  in  number    default null
  ,p_spcl_rt_oipl_id                in  number    default null
  ,p_must_enrl_anthr_pl_id          in  number    default null
  ,p_int_elig_per_elctbl_chc_id          in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                    in  number    default null
  ,p_ptip_ordr_num                    in  number    default null
  ,p_oipl_ordr_num                    in  number    default null
  -- cwb
  ,p_comments                        in  varchar2   default null
  ,p_elig_flag                       in  varchar2   default 'Y'
  ,p_elig_ovrid_dt                   in  date       default null
  ,p_elig_ovrid_person_id            in  number     default null
  ,p_inelig_rsn_cd                   in  varchar2   default null
  ,p_mgr_ovrid_dt                    in  date       default null
  ,p_mgr_ovrid_person_id             in  number     default null
  ,p_ws_mgr_id                       in  number     default null
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default null
  ,p_epe_attribute1                 in  varchar2  default null
  ,p_epe_attribute2                 in  varchar2  default null
  ,p_epe_attribute3                 in  varchar2  default null
  ,p_epe_attribute4                 in  varchar2  default null
  ,p_epe_attribute5                 in  varchar2  default null
  ,p_epe_attribute6                 in  varchar2  default null
  ,p_epe_attribute7                 in  varchar2  default null
  ,p_epe_attribute8                 in  varchar2  default null
  ,p_epe_attribute9                 in  varchar2  default null
  ,p_epe_attribute10                in  varchar2  default null
  ,p_epe_attribute11                in  varchar2  default null
  ,p_epe_attribute12                in  varchar2  default null
  ,p_epe_attribute13                in  varchar2  default null
  ,p_epe_attribute14                in  varchar2  default null
  ,p_epe_attribute15                in  varchar2  default null
  ,p_epe_attribute16                in  varchar2  default null
  ,p_epe_attribute17                in  varchar2  default null
  ,p_epe_attribute18                in  varchar2  default null
  ,p_epe_attribute19                in  varchar2  default null
  ,p_epe_attribute20                in  varchar2  default null
  ,p_epe_attribute21                in  varchar2  default null
  ,p_epe_attribute22                in  varchar2  default null
  ,p_epe_attribute23                in  varchar2  default null
  ,p_epe_attribute24                in  varchar2  default null
  ,p_epe_attribute25                in  varchar2  default null
  ,p_epe_attribute26                in  varchar2  default null
  ,p_epe_attribute27                in  varchar2  default null
  ,p_epe_attribute28                in  varchar2  default null
  ,p_epe_attribute29                in  varchar2  default null
  ,p_epe_attribute30                in  varchar2  default null
  ,p_approval_status_cd             in  varchar2  default null
  ,p_fonm_cvg_strt_dt               in  date      default null
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  -- CWB Changes
  ,p_mode                           in  varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_PER_ELC_CHC >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_elig_per_elctbl_chc_id       Yes  number    PK of record
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_perd_end_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_enrt_cvg_strt_dt_rl          No   varchar2
--   p_rt_strt_dt                   No   date
--   p_rt_strt_dt_rl                No   varchar2
--   p_rt_strt_dt_cd                No   varchar2
--   p_roll_crs_flag           No   varchar2
--   p_crntly_enrd_flag             Yes  varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_elctbl_flag                  Yes  varchar2
--   p_mndtry_flag                  Yes  varchar2
--   p_in_pndg_wkflow_flag          No   varchar2
--   p_dflt_enrt_dt                 No   date
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   varchar2
--   p_enrt_cvg_strt_dt             No   date
--   p_alws_dpnt_dsgn_flag          Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_ler_chg_dpnt_cvg_cd          No   varchar2
--   p_erlst_deenrt_dt              No   date
--   p_procg_end_dt                 No   date
--   p_comp_lvl_cd                  No   varchar2
--   p_pl_id                        Yes  number
--   p_oipl_id                      No   number
--   p_pgm_id                       No   number
--   p_plip_id                      No   number
--   p_ptip_id                      No   number
--   p_pl_typ_id                    No   number
--   p_oiplip_id                    No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_assignment_id                No   number
--   p_spcl_rt_pl_id                Yes  number
--   p_spcl_rt_oipl_id              Yes  number
--   p_must_enrl_anthr_pl_id        Yes  number
--   p_int_elig_per_elctbl_chc_id        Yes  number
--   p_prtt_enrt_rslt_id            No   number
--   p_bnft_prvdr_pool_id           Yes  number
--   p_per_in_ler_id                Yes  number
--   p_yr_perd_id                   No   number
--   p_auto_enrt_flag               No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_epe_attribute_category       No   varchar2  Descriptive Flexfield
--   p_epe_attribute1               No   varchar2  Descriptive Flexfield
--   p_epe_attribute2               No   varchar2  Descriptive Flexfield
--   p_epe_attribute3               No   varchar2  Descriptive Flexfield
--   p_epe_attribute4               No   varchar2  Descriptive Flexfield
--   p_epe_attribute5               No   varchar2  Descriptive Flexfield
--   p_epe_attribute6               No   varchar2  Descriptive Flexfield
--   p_epe_attribute7               No   varchar2  Descriptive Flexfield
--   p_epe_attribute8               No   varchar2  Descriptive Flexfield
--   p_epe_attribute9               No   varchar2  Descriptive Flexfield
--   p_epe_attribute10              No   varchar2  Descriptive Flexfield
--   p_epe_attribute11              No   varchar2  Descriptive Flexfield
--   p_epe_attribute12              No   varchar2  Descriptive Flexfield
--   p_epe_attribute13              No   varchar2  Descriptive Flexfield
--   p_epe_attribute14              No   varchar2  Descriptive Flexfield
--   p_epe_attribute15              No   varchar2  Descriptive Flexfield
--   p_epe_attribute16              No   varchar2  Descriptive Flexfield
--   p_epe_attribute17              No   varchar2  Descriptive Flexfield
--   p_epe_attribute18              No   varchar2  Descriptive Flexfield
--   p_epe_attribute19              No   varchar2  Descriptive Flexfield
--   p_epe_attribute20              No   varchar2  Descriptive Flexfield
--   p_epe_attribute21              No   varchar2  Descriptive Flexfield
--   p_epe_attribute22              No   varchar2  Descriptive Flexfield
--   p_epe_attribute23              No   varchar2  Descriptive Flexfield
--   p_epe_attribute24              No   varchar2  Descriptive Flexfield
--   p_epe_attribute25              No   varchar2  Descriptive Flexfield
--   p_epe_attribute26              No   varchar2  Descriptive Flexfield
--   p_epe_attribute27              No   varchar2  Descriptive Flexfield
--   p_epe_attribute28              No   varchar2  Descriptive Flexfield
--   p_epe_attribute29              No   varchar2  Descriptive Flexfield
--   p_epe_attribute30              No   varchar2  Descriptive Flexfield
--   p_cryfwd_elig_dpnt_cd          No   varchar2
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ELIG_PER_ELC_CHC
  (
   p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
--  ,p_rt_strt_dt                     in  date      default hr_api.g_date
--  ,p_rt_strt_dt_rl                  in  varchar2  default hr_api.g_varchar2
--  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id         in  number    default hr_api.g_number
  ,p_roll_crs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_pl_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_oipl_id                in  number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id          in  number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id          in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
  ,p_oipl_ordr_num                    in  number    default hr_api.g_number
  -- cwb
  ,p_comments                        in  varchar2       default hr_api.g_varchar2
  ,p_elig_flag                       in  varchar2       default hr_api.g_varchar2
  ,p_elig_ovrid_dt                   in  date           default hr_api.g_date
  ,p_elig_ovrid_person_id            in  number         default hr_api.g_number
  ,p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                    in  date           default hr_api.g_date
  ,p_mgr_ovrid_person_id             in  number         default hr_api.g_number
  ,p_ws_mgr_id                       in  number         default hr_api.g_number
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_approval_status_cd             in  varchar2  default hr_api.g_varchar2
  ,p_fonm_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- Performance cover
--
procedure update_perf_ELIG_PER_ELC_CHC
  (p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         in  number
  -- ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  -- ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  -- ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id         in  number    default hr_api.g_number
  ,p_roll_crs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2  default hr_api.g_varchar2
  -- ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_pl_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_oipl_id                in  number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id          in  number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id          in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
  ,p_oipl_ordr_num                    in  number    default hr_api.g_number
  -- cwb
  ,p_comments                        in  varchar2       default hr_api.g_varchar2
  ,p_elig_flag                       in  varchar2       default hr_api.g_varchar2
  ,p_elig_ovrid_dt                   in  date           default hr_api.g_date
  ,p_elig_ovrid_person_id            in  number         default hr_api.g_number
  ,p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                    in  date           default hr_api.g_date
  ,p_mgr_ovrid_person_id             in  number         default hr_api.g_number
  ,p_ws_mgr_id                       in  number         default hr_api.g_number
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_approval_status_cd             in  varchar2  default hr_api.g_varchar2
  ,p_fonm_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_PER_ELC_CHC >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_elig_per_elctbl_chc_id       Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_ELIG_PER_ELC_CHC
  (
   p_validate                       in boolean        default false
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_elig_per_elctbl_chc_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_elig_per_elctbl_chc_id                 in number
   ,p_object_version_number        in number
  );
--
procedure CreOrSel_pil_elctbl_chc_popl
  (p_per_in_ler_id          in     number
  ,p_effective_date         in     date
  ,p_business_group_id      in     number
  ,p_pgm_id                 in     number
  ,p_plip_id                in     number
  ,p_pl_id                  in     number
  ,p_oipl_id                in     number
  ,p_yr_perd_id             in     number
  ,p_uom                    in     varchar2
  ,p_acty_ref_perd_cd       in     varchar2
  ,p_dflt_enrt_dt           in     date
  ,p_cls_enrt_dt_to_use_cd  in     varchar2
  ,p_enrt_typ_cycl_cd       in     varchar2
  ,p_enrt_perd_end_dt       in     date
  ,p_enrt_perd_strt_dt      in     date
  ,p_procg_end_dt           in     date
  ,p_lee_rsn_id             in     number
  ,p_enrt_perd_id           in     number
  ,p_request_id             in     number
  ,p_program_application_id in     number
  ,p_program_id             in     number
  ,p_program_update_date    in     date
  ,p_ws_mgr_id              in     number
  ,p_assignment_id          in     number
  --
  ,p_pil_elctbl_chc_popl_id    out nocopy number
  ,p_oiplip_id                 out nocopy number
  );
--
end ben_ELIG_PER_ELC_CHC_api;

 

/
