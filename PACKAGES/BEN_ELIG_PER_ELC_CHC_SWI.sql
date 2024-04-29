--------------------------------------------------------
--  DDL for Package BEN_ELIG_PER_ELC_CHC_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PER_ELC_CHC_SWI" AUTHID CURRENT_USER As
/* $Header: beepeswi.pkh 120.3 2006/01/06 05:29:54 narvenka noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.create_elig_per_elc_chc
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id          out nocopy number
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_pil_elctbl_chc_popl_id       in     number    default null
  ,p_roll_crs_flag                in     varchar2  default null
  ,p_crntly_enrd_flag             in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_elctbl_flag                  in     varchar2  default null
  ,p_mndtry_flag                  in     varchar2  default null
  ,p_in_pndg_wkflow_flag          in     varchar2  default null
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_enrt_cvg_strt_dt             in     date      default null
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default null
  ,p_dpnt_dsgn_cd                 in     varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default null
  ,p_erlst_deenrt_dt              in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_comp_lvl_cd                  in     varchar2  default null
  ,p_pl_id                        in     number    default null
  ,p_oipl_id                      in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pgm_typ_cd                   in     varchar2  default null
  ,p_plip_id                      in     number    default null
  ,p_ptip_id                      in     number    default null
  ,p_pl_typ_id                    in     number    default null
  ,p_oiplip_id                    in     number    default null
  ,p_cmbn_plip_id                 in     number    default null
  ,p_cmbn_ptip_id                 in     number    default null
  ,p_cmbn_ptip_opt_id             in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_spcl_rt_pl_id                in     number    default null
  ,p_spcl_rt_oipl_id              in     number    default null
  ,p_must_enrl_anthr_pl_id        in     number    default null
  ,p_int_elig_per_elctbl_chc_id   in     number    default null
  ,p_prtt_enrt_rslt_id            in     number    default null
  ,p_bnft_prvdr_pool_id           in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_yr_perd_id                   in     number    default null
  ,p_auto_enrt_flag               in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_pl_ordr_num                  in     number    default null
  ,p_plip_ordr_num                in     number    default null
  ,p_ptip_ordr_num                in     number    default null
  ,p_oipl_ordr_num                in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_elig_flag                    in     varchar2  default null
  ,p_elig_ovrid_dt                in     date      default null
  ,p_elig_ovrid_person_id         in     number    default null
  ,p_inelig_rsn_cd                in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_epe_attribute_category       in     varchar2  default null
  ,p_epe_attribute1               in     varchar2  default null
  ,p_epe_attribute2               in     varchar2  default null
  ,p_epe_attribute3               in     varchar2  default null
  ,p_epe_attribute4               in     varchar2  default null
  ,p_epe_attribute5               in     varchar2  default null
  ,p_epe_attribute6               in     varchar2  default null
  ,p_epe_attribute7               in     varchar2  default null
  ,p_epe_attribute8               in     varchar2  default null
  ,p_epe_attribute9               in     varchar2  default null
  ,p_epe_attribute10              in     varchar2  default null
  ,p_epe_attribute11              in     varchar2  default null
  ,p_epe_attribute12              in     varchar2  default null
  ,p_epe_attribute13              in     varchar2  default null
  ,p_epe_attribute14              in     varchar2  default null
  ,p_epe_attribute15              in     varchar2  default null
  ,p_epe_attribute16              in     varchar2  default null
  ,p_epe_attribute17              in     varchar2  default null
  ,p_epe_attribute18              in     varchar2  default null
  ,p_epe_attribute19              in     varchar2  default null
  ,p_epe_attribute20              in     varchar2  default null
  ,p_epe_attribute21              in     varchar2  default null
  ,p_epe_attribute22              in     varchar2  default null
  ,p_epe_attribute23              in     varchar2  default null
  ,p_epe_attribute24              in     varchar2  default null
  ,p_epe_attribute25              in     varchar2  default null
  ,p_epe_attribute26              in     varchar2  default null
  ,p_epe_attribute27              in     varchar2  default null
  ,p_epe_attribute28              in     varchar2  default null
  ,p_epe_attribute29              in     varchar2  default null
  ,p_epe_attribute30              in     varchar2  default null
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_enrt_perd_id                 in     number    default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_approval_status_cd           in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_perf_elig_per_elc_chc >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_perf_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id          out nocopy number
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_pil_elctbl_chc_popl_id       in     number    default null
  ,p_roll_crs_flag                in     varchar2  default null
  ,p_crntly_enrd_flag             in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_elctbl_flag                  in     varchar2  default null
  ,p_mndtry_flag                  in     varchar2  default null
  ,p_in_pndg_wkflow_flag          in     varchar2  default null
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_enrt_cvg_strt_dt             in     date      default null
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default null
  ,p_dpnt_dsgn_cd                 in     varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default null
  ,p_erlst_deenrt_dt              in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_comp_lvl_cd                  in     varchar2  default null
  ,p_pl_id                        in     number    default null
  ,p_oipl_id                      in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pgm_typ_cd                   in     varchar2  default null
  ,p_plip_id                      in     number    default null
  ,p_ptip_id                      in     number    default null
  ,p_pl_typ_id                    in     number    default null
  ,p_oiplip_id                    in     number    default null
  ,p_cmbn_plip_id                 in     number    default null
  ,p_cmbn_ptip_id                 in     number    default null
  ,p_cmbn_ptip_opt_id             in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_spcl_rt_pl_id                in     number    default null
  ,p_spcl_rt_oipl_id              in     number    default null
  ,p_must_enrl_anthr_pl_id        in     number    default null
  ,p_int_elig_per_elctbl_chc_id   in     number    default null
  ,p_prtt_enrt_rslt_id            in     number    default null
  ,p_bnft_prvdr_pool_id           in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_yr_perd_id                   in     number    default null
  ,p_auto_enrt_flag               in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_pl_ordr_num                  in     number    default null
  ,p_plip_ordr_num                in     number    default null
  ,p_ptip_ordr_num                in     number    default null
  ,p_oipl_ordr_num                in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_elig_flag                    in     varchar2  default null
  ,p_elig_ovrid_dt                in     date      default null
  ,p_elig_ovrid_person_id         in     number    default null
  ,p_inelig_rsn_cd                in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_epe_attribute_category       in     varchar2  default null
  ,p_epe_attribute1               in     varchar2  default null
  ,p_epe_attribute2               in     varchar2  default null
  ,p_epe_attribute3               in     varchar2  default null
  ,p_epe_attribute4               in     varchar2  default null
  ,p_epe_attribute5               in     varchar2  default null
  ,p_epe_attribute6               in     varchar2  default null
  ,p_epe_attribute7               in     varchar2  default null
  ,p_epe_attribute8               in     varchar2  default null
  ,p_epe_attribute9               in     varchar2  default null
  ,p_epe_attribute10              in     varchar2  default null
  ,p_epe_attribute11              in     varchar2  default null
  ,p_epe_attribute12              in     varchar2  default null
  ,p_epe_attribute13              in     varchar2  default null
  ,p_epe_attribute14              in     varchar2  default null
  ,p_epe_attribute15              in     varchar2  default null
  ,p_epe_attribute16              in     varchar2  default null
  ,p_epe_attribute17              in     varchar2  default null
  ,p_epe_attribute18              in     varchar2  default null
  ,p_epe_attribute19              in     varchar2  default null
  ,p_epe_attribute20              in     varchar2  default null
  ,p_epe_attribute21              in     varchar2  default null
  ,p_epe_attribute22              in     varchar2  default null
  ,p_epe_attribute23              in     varchar2  default null
  ,p_epe_attribute24              in     varchar2  default null
  ,p_epe_attribute25              in     varchar2  default null
  ,p_epe_attribute26              in     varchar2  default null
  ,p_epe_attribute27              in     varchar2  default null
  ,p_epe_attribute28              in     varchar2  default null
  ,p_epe_attribute29              in     varchar2  default null
  ,p_epe_attribute30              in     varchar2  default null
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_enrt_perd_id                 in     number    default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_mode                         in     varchar2  default null
  ,p_approval_status_cd           in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.delete_elig_per_elc_chc
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.lck
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_elig_per_elctbl_chc_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.update_elig_per_elc_chc
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_enrt_typ_cycl_cd             in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_strt_dt            in     date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id       in     number    default hr_api.g_number
  ,p_roll_crs_flag                in     varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                 in     date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt             in     date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt              in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_comp_lvl_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_oipl_id                      in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_plip_id                      in     number    default hr_api.g_number
  ,p_ptip_id                      in     number    default hr_api.g_number
  ,p_pl_typ_id                    in     number    default hr_api.g_number
  ,p_oiplip_id                    in     number    default hr_api.g_number
  ,p_cmbn_plip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id             in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_spcl_rt_pl_id                in     number    default hr_api.g_number
  ,p_spcl_rt_oipl_id              in     number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id        in     number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id   in     number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id            in     number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id           in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_yr_perd_id                   in     number    default hr_api.g_number
  ,p_auto_enrt_flag               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pl_ordr_num                  in     number    default hr_api.g_number
  ,p_plip_ordr_num                in     number    default hr_api.g_number
  ,p_ptip_ordr_num                in     number    default hr_api.g_number
  ,p_oipl_ordr_num                in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_epe_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_approval_status_cd           in  varchar2     default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_perf_elig_per_elc_chc >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_perf_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id       in     number    default hr_api.g_number
  ,p_roll_crs_flag                in     varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt             in     date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt              in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_comp_lvl_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_oipl_id                      in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_plip_id                      in     number    default hr_api.g_number
  ,p_ptip_id                      in     number    default hr_api.g_number
  ,p_pl_typ_id                    in     number    default hr_api.g_number
  ,p_oiplip_id                    in     number    default hr_api.g_number
  ,p_cmbn_plip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id             in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_spcl_rt_pl_id                in     number    default hr_api.g_number
  ,p_spcl_rt_oipl_id              in     number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id        in     number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id   in     number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id            in     number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id           in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_yr_perd_id                   in     number    default hr_api.g_number
  ,p_auto_enrt_flag               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pl_ordr_num                  in     number    default hr_api.g_number
  ,p_plip_ordr_num                in     number    default hr_api.g_number
  ,p_ptip_ordr_num                in     number    default hr_api.g_number
  ,p_oipl_ordr_num                in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_epe_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_approval_status_cd           in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------
  procedure process_api
  (
   p_document            in         CLOB
  ,p_return_status       out nocopy VARCHAR2
  ,p_validate            in         number    default hr_api.g_false_num
  ,p_effective_date      in         date      default null
  );

end ben_elig_per_elc_chc_swi;

 

/
