--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_RATE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_RATE_SWI" AUTHID CURRENT_USER As
/* $Header: beecrswi.pkh 120.3 2006/01/06 05:13:47 narvenka noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_enrollment_rate_api.create_enrollment_rate
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
PROCEDURE create_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                      out nocopy number
  ,p_ordr_num			  in     number    default null
  ,p_acty_typ_cd                  in     varchar2  default null
  ,p_tx_typ_cd                    in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default null
  ,p_dsply_on_enrt_flag           in     varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default null
  ,p_entr_val_at_enrt_flag        in     varchar2  default null
  ,p_asn_on_enrt_flag             in     varchar2  default null
  ,p_rl_crs_only_flag             in     varchar2  default null
  ,p_dflt_val                     in     number    default null
  ,p_ann_val                      in     number    default null
  ,p_ann_mn_elcn_val              in     number    default null
  ,p_ann_mx_elcn_val              in     number    default null
  ,p_val                          in     number    default null
  ,p_nnmntry_uom                  in     varchar2  default null
  ,p_mx_elcn_val                  in     number    default null
  ,p_mn_elcn_val                  in     number    default null
  ,p_incrmt_elcn_val              in     number    default null
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default null
  ,p_cmcd_mn_elcn_val             in     number    default null
  ,p_cmcd_mx_elcn_val             in     number    default null
  ,p_cmcd_val                     in     number    default null
  ,p_cmcd_dflt_val                in     number    default null
  ,p_rt_usg_cd                    in     varchar2  default null
  ,p_ann_dflt_val                 in     number    default null
  ,p_bnft_rt_typ_cd               in     varchar2  default null
  ,p_rt_mlt_cd                    in     varchar2  default null
  ,p_dsply_mn_elcn_val            in     number    default null
  ,p_dsply_mx_elcn_val            in     number    default null
  ,p_entr_ann_val_flag            in     varchar2  default null
  ,p_rt_strt_dt                   in     date      default null
  ,p_rt_strt_dt_cd                in     varchar2  default null
  ,p_rt_strt_dt_rl                in     number    default null
  ,p_rt_typ_cd                    in     varchar2  default null
  ,p_elig_per_elctbl_chc_id       in     number    default null
  ,p_acty_base_rt_id              in     number    default null
  ,p_spcl_rt_enrt_rt_id           in     number    default null
  ,p_enrt_bnft_id                 in     number    default null
  ,p_prtt_rt_val_id               in     number    default null
  ,p_decr_bnft_prvdr_pool_id      in     number    default null
  ,p_cvg_amt_calc_mthd_id         in     number    default null
  ,p_actl_prem_id                 in     number    default null
  ,p_comp_lvl_fctr_id             in     number    default null
  ,p_ptd_comp_lvl_fctr_id         in     number    default null
  ,p_clm_comp_lvl_fctr_id         in     number    default null
  ,p_business_group_id            in     number
  ,p_perf_min_max_edit            in     varchar2  default null
  ,p_iss_val                      in     number    default null
  ,p_val_last_upd_date            in     date      default null
  ,p_val_last_upd_person_id       in     number    default null
  ,p_pp_in_yr_used_num            in     number    default null
  ,p_ecr_attribute_category       in     varchar2  default null
  ,p_ecr_attribute1               in     varchar2  default null
  ,p_ecr_attribute2               in     varchar2  default null
  ,p_ecr_attribute3               in     varchar2  default null
  ,p_ecr_attribute4               in     varchar2  default null
  ,p_ecr_attribute5               in     varchar2  default null
  ,p_ecr_attribute6               in     varchar2  default null
  ,p_ecr_attribute7               in     varchar2  default null
  ,p_ecr_attribute8               in     varchar2  default null
  ,p_ecr_attribute9               in     varchar2  default null
  ,p_ecr_attribute10              in     varchar2  default null
  ,p_ecr_attribute11              in     varchar2  default null
  ,p_ecr_attribute12              in     varchar2  default null
  ,p_ecr_attribute13              in     varchar2  default null
  ,p_ecr_attribute14              in     varchar2  default null
  ,p_ecr_attribute15              in     varchar2  default null
  ,p_ecr_attribute16              in     varchar2  default null
  ,p_ecr_attribute17              in     varchar2  default null
  ,p_ecr_attribute18              in     varchar2  default null
  ,p_ecr_attribute19              in     varchar2  default null
  ,p_ecr_attribute20              in     varchar2  default null
  ,p_ecr_attribute21              in     varchar2  default null
  ,p_ecr_attribute22              in     varchar2  default null
  ,p_ecr_attribute23              in     varchar2  default null
  ,p_ecr_attribute24              in     varchar2  default null
  ,p_ecr_attribute25              in     varchar2  default null
  ,p_ecr_attribute26              in     varchar2  default null
  ,p_ecr_attribute27              in     varchar2  default null
  ,p_ecr_attribute28              in     varchar2  default null
  ,p_ecr_attribute29              in     varchar2  default null
  ,p_ecr_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< create_perf_enrollment_rate >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_enrollment_rate_api.create_perf_enrollment_rate
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
PROCEDURE create_perf_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                      out nocopy number
  ,p_ordr_num			  in     number    default null
  ,p_acty_typ_cd                  in     varchar2  default null
  ,p_tx_typ_cd                    in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default null
  ,p_dsply_on_enrt_flag           in     varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default null
  ,p_entr_val_at_enrt_flag        in     varchar2  default null
  ,p_asn_on_enrt_flag             in     varchar2  default null
  ,p_rl_crs_only_flag             in     varchar2  default null
  ,p_dflt_val                     in     number    default null
  ,p_ann_val                      in     number    default null
  ,p_ann_mn_elcn_val              in     number    default null
  ,p_ann_mx_elcn_val              in     number    default null
  ,p_val                          in     number    default null
  ,p_nnmntry_uom                  in     varchar2  default null
  ,p_mx_elcn_val                  in     number    default null
  ,p_mn_elcn_val                  in     number    default null
  ,p_incrmt_elcn_val              in     number    default null
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default null
  ,p_cmcd_mn_elcn_val             in     number    default null
  ,p_cmcd_mx_elcn_val             in     number    default null
  ,p_cmcd_val                     in     number    default null
  ,p_cmcd_dflt_val                in     number    default null
  ,p_rt_usg_cd                    in     varchar2  default null
  ,p_ann_dflt_val                 in     number    default null
  ,p_bnft_rt_typ_cd               in     varchar2  default null
  ,p_rt_mlt_cd                    in     varchar2  default null
  ,p_dsply_mn_elcn_val            in     number    default null
  ,p_dsply_mx_elcn_val            in     number    default null
  ,p_entr_ann_val_flag            in     varchar2
  ,p_rt_strt_dt                   in     date      default null
  ,p_rt_strt_dt_cd                in     varchar2  default null
  ,p_rt_strt_dt_rl                in     number    default null
  ,p_rt_typ_cd                    in     varchar2  default null
  ,p_elig_per_elctbl_chc_id       in     number    default null
  ,p_acty_base_rt_id              in     number    default null
  ,p_spcl_rt_enrt_rt_id           in     number    default null
  ,p_enrt_bnft_id                 in     number    default null
  ,p_prtt_rt_val_id               in     number    default null
  ,p_decr_bnft_prvdr_pool_id      in     number    default null
  ,p_cvg_amt_calc_mthd_id         in     number    default null
  ,p_actl_prem_id                 in     number    default null
  ,p_comp_lvl_fctr_id             in     number    default null
  ,p_ptd_comp_lvl_fctr_id         in     number    default null
  ,p_clm_comp_lvl_fctr_id         in     number    default null
  ,p_business_group_id            in     number
  ,p_perf_min_max_edit            in     varchar2  default null
  ,p_iss_val                      in     number    default null
  ,p_val_last_upd_date            in     date      default null
  ,p_val_last_upd_person_id       in     number    default null
  ,p_pp_in_yr_used_num            in     number    default null
  ,p_ecr_attribute_category       in     varchar2  default null
  ,p_ecr_attribute1               in     varchar2  default null
  ,p_ecr_attribute2               in     varchar2  default null
  ,p_ecr_attribute3               in     varchar2  default null
  ,p_ecr_attribute4               in     varchar2  default null
  ,p_ecr_attribute5               in     varchar2  default null
  ,p_ecr_attribute6               in     varchar2  default null
  ,p_ecr_attribute7               in     varchar2  default null
  ,p_ecr_attribute8               in     varchar2  default null
  ,p_ecr_attribute9               in     varchar2  default null
  ,p_ecr_attribute10              in     varchar2  default null
  ,p_ecr_attribute11              in     varchar2  default null
  ,p_ecr_attribute12              in     varchar2  default null
  ,p_ecr_attribute13              in     varchar2  default null
  ,p_ecr_attribute14              in     varchar2  default null
  ,p_ecr_attribute15              in     varchar2  default null
  ,p_ecr_attribute16              in     varchar2  default null
  ,p_ecr_attribute17              in     varchar2  default null
  ,p_ecr_attribute18              in     varchar2  default null
  ,p_ecr_attribute19              in     varchar2  default null
  ,p_ecr_attribute20              in     varchar2  default null
  ,p_ecr_attribute21              in     varchar2  default null
  ,p_ecr_attribute22              in     varchar2  default null
  ,p_ecr_attribute23              in     varchar2  default null
  ,p_ecr_attribute24              in     varchar2  default null
  ,p_ecr_attribute25              in     varchar2  default null
  ,p_ecr_attribute26              in     varchar2  default null
  ,p_ecr_attribute27              in     varchar2  default null
  ,p_ecr_attribute28              in     varchar2  default null
  ,p_ecr_attribute29              in     varchar2  default null
  ,p_ecr_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_enrollment_rate_api.delete_enrollment_rate
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
PROCEDURE delete_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                   in     number
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
--  API: ben_enrollment_rate_api.lck
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
  (p_enrt_rt_id                   in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< override_enrollment_rate >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_enrollment_rate_api.override_enrollment_rate
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
PROCEDURE override_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_enrt_rt_id                   in     number
  ,p_ordr_num	                  in     number     default hr_api.g_number
  ,p_acty_typ_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag           in     varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag        in     varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag             in     varchar2  default hr_api.g_varchar2
  ,p_rl_crs_only_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_val                     in     number    default hr_api.g_number
  ,p_old_ann_val                  in     number    default hr_api.g_number
  ,p_ann_val                      in     number    default hr_api.g_number
  ,p_ann_mn_elcn_val              in     number    default hr_api.g_number
  ,p_ann_mx_elcn_val              in     number    default hr_api.g_number
  ,p_old_val                      in     number    default hr_api.g_number
  ,p_val                          in     number    default hr_api.g_number
  ,p_nnmntry_uom                  in     varchar2  default hr_api.g_varchar2
  ,p_mx_elcn_val                  in     number    default hr_api.g_number
  ,p_mn_elcn_val                  in     number    default hr_api.g_number
  ,p_incrmt_elcn_val              in     number    default hr_api.g_number
  ,p_acty_ref_perd_cd             in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_mn_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_mx_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_val                     in     number    default hr_api.g_number
  ,p_cmcd_dflt_val                in     number    default hr_api.g_number
  ,p_rt_usg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ann_dflt_val                 in     number    default hr_api.g_number
  ,p_bnft_rt_typ_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_dsply_mn_elcn_val            in     number    default hr_api.g_number
  ,p_dsply_mx_elcn_val            in     number    default hr_api.g_number
  ,p_entr_ann_val_flag            in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt                   in     date      default hr_api.g_date
  ,p_rt_strt_dt_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                in     number    default hr_api.g_number
  ,p_rt_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id       in     number    default hr_api.g_number
  ,p_acty_base_rt_id              in     number    default hr_api.g_number
  ,p_spcl_rt_enrt_rt_id           in     number    default hr_api.g_number
  ,p_enrt_bnft_id                 in     number    default hr_api.g_number
  ,p_prtt_rt_val_id               in     number    default hr_api.g_number
  ,p_decr_bnft_prvdr_pool_id      in     number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id         in     number    default hr_api.g_number
  ,p_actl_prem_id                 in     number    default hr_api.g_number
  ,p_comp_lvl_fctr_id             in     number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_perf_min_max_edit            in     varchar2  default hr_api.g_varchar2
  ,p_iss_val                      in     number    default hr_api.g_number
  ,p_val_last_upd_date            in     date      default hr_api.g_date
  ,p_val_last_upd_person_id       in     number    default hr_api.g_number
  ,p_pp_in_yr_used_num            in     number    default hr_api.g_number
  ,p_ecr_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_enrollment_rate_api.update_enrollment_rate
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
PROCEDURE update_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                   in     number
  ,p_ordr_num			  in number     default hr_api.g_number
  ,p_acty_typ_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag           in     varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag        in     varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag             in     varchar2  default hr_api.g_varchar2
  ,p_rl_crs_only_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_val                     in     number    default hr_api.g_number
  ,p_ann_val                      in     number    default hr_api.g_number
  ,p_ann_mn_elcn_val              in     number    default hr_api.g_number
  ,p_ann_mx_elcn_val              in     number    default hr_api.g_number
  ,p_val                          in     number    default hr_api.g_number
  ,p_nnmntry_uom                  in     varchar2  default hr_api.g_varchar2
  ,p_mx_elcn_val                  in     number    default hr_api.g_number
  ,p_mn_elcn_val                  in     number    default hr_api.g_number
  ,p_incrmt_elcn_val              in     number    default hr_api.g_number
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_mn_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_mx_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_val                     in     number    default hr_api.g_number
  ,p_cmcd_dflt_val                in     number    default hr_api.g_number
  ,p_rt_usg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ann_dflt_val                 in     number    default hr_api.g_number
  ,p_bnft_rt_typ_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_dsply_mn_elcn_val            in     number    default hr_api.g_number
  ,p_dsply_mx_elcn_val            in     number    default hr_api.g_number
  ,p_entr_ann_val_flag            in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt                   in     date      default hr_api.g_date
  ,p_rt_strt_dt_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                in     number    default hr_api.g_number
  ,p_rt_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id       in     number    default hr_api.g_number
  ,p_acty_base_rt_id              in     number    default hr_api.g_number
  ,p_spcl_rt_enrt_rt_id           in     number    default hr_api.g_number
  ,p_enrt_bnft_id                 in     number    default hr_api.g_number
  ,p_prtt_rt_val_id               in     number    default hr_api.g_number
  ,p_decr_bnft_prvdr_pool_id      in     number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id         in     number    default hr_api.g_number
  ,p_actl_prem_id                 in     number    default hr_api.g_number
  ,p_comp_lvl_fctr_id             in     number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_perf_min_max_edit            in     varchar2  default hr_api.g_varchar2
  ,p_iss_val                      in     number    default hr_api.g_number
  ,p_val_last_upd_date            in     date      default hr_api.g_date
  ,p_val_last_upd_person_id       in     number    default hr_api.g_number
  ,p_pp_in_yr_used_num            in     number    default hr_api.g_number
  ,p_ecr_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< process_api >----------------------------------|
-- ----------------------------------------------------------------------------

procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);

end ben_enrollment_rate_swi;

 

/
