--------------------------------------------------------
--  DDL for Package BEN_PIL_ELCTBL_CHC_POPL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ELCTBL_CHC_POPL_SWI" AUTHID CURRENT_USER As
/* $Header: bepelswi.pkh 115.0 2003/03/10 15:20:17 aupadhya noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_elctbl_chc_popl_api.create_pil_elctbl_chc_popl
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
PROCEDURE create_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id          out nocopy number
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dflt_asnd_dt                 in     date      default null
  ,p_elcns_made_dt                in     date      default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_pil_elctbl_popl_stat_cd      in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_bdgt_acc_cd                  in     varchar2  default null
  ,p_pop_cd                       in     varchar2  default null
  ,p_bdgt_due_dt                  in     date      default null
  ,p_bdgt_export_flag             in     varchar2  default null
  ,p_bdgt_iss_dt                  in     date      default null
  ,p_bdgt_stat_cd                 in     varchar2  default null
  ,p_ws_acc_cd                    in     varchar2  default null
  ,p_ws_due_dt                    in     date      default null
  ,p_ws_export_flag               in     varchar2  default null
  ,p_ws_iss_dt                    in     date      default null
  ,p_ws_stat_cd                   in     varchar2  default null
  ,p_auto_asnd_dt                 in     date      default null
  ,p_cbr_elig_perd_strt_dt        in     date      default null
  ,p_cbr_elig_perd_end_dt         in     date      default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_enrt_perd_id                 in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pl_id                        in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_pel_attribute_category       in     varchar2  default null
  ,p_pel_attribute1               in     varchar2  default null
  ,p_pel_attribute2               in     varchar2  default null
  ,p_pel_attribute3               in     varchar2  default null
  ,p_pel_attribute4               in     varchar2  default null
  ,p_pel_attribute5               in     varchar2  default null
  ,p_pel_attribute6               in     varchar2  default null
  ,p_pel_attribute7               in     varchar2  default null
  ,p_pel_attribute8               in     varchar2  default null
  ,p_pel_attribute9               in     varchar2  default null
  ,p_pel_attribute10              in     varchar2  default null
  ,p_pel_attribute11              in     varchar2  default null
  ,p_pel_attribute12              in     varchar2  default null
  ,p_pel_attribute13              in     varchar2  default null
  ,p_pel_attribute14              in     varchar2  default null
  ,p_pel_attribute15              in     varchar2  default null
  ,p_pel_attribute16              in     varchar2  default null
  ,p_pel_attribute17              in     varchar2  default null
  ,p_pel_attribute18              in     varchar2  default null
  ,p_pel_attribute19              in     varchar2  default null
  ,p_pel_attribute20              in     varchar2  default null
  ,p_pel_attribute21              in     varchar2  default null
  ,p_pel_attribute22              in     varchar2  default null
  ,p_pel_attribute23              in     varchar2  default null
  ,p_pel_attribute24              in     varchar2  default null
  ,p_pel_attribute25              in     varchar2  default null
  ,p_pel_attribute26              in     varchar2  default null
  ,p_pel_attribute27              in     varchar2  default null
  ,p_pel_attribute28              in     varchar2  default null
  ,p_pel_attribute29              in     varchar2  default null
  ,p_pel_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_elctbl_chc_popl_api.delete_pil_elctbl_chc_popl
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
PROCEDURE delete_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id       in     number
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
--  API: ben_pil_elctbl_chc_popl_api.lck
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
  (p_pil_elctbl_chc_popl_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
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
PROCEDURE update_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id       in     number
  ,p_dflt_enrt_dt                 in     date      default hr_api.g_date
  ,p_dflt_asnd_dt                 in     date      default hr_api.g_date
  ,p_elcns_made_dt                in     date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default hr_api.g_varchar2
  ,p_enrt_typ_cycl_cd             in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_strt_dt            in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_pil_elctbl_popl_stat_cd      in     varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd             in     varchar2  default hr_api.g_varchar2
  ,p_uom                          in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_bdgt_acc_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pop_cd                       in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_due_dt                  in     date      default hr_api.g_date
  ,p_bdgt_export_flag             in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_iss_dt                  in     date      default hr_api.g_date
  ,p_bdgt_stat_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_acc_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ws_due_dt                    in     date      default hr_api.g_date
  ,p_ws_export_flag               in     varchar2  default hr_api.g_varchar2
  ,p_ws_iss_dt                    in     date      default hr_api.g_date
  ,p_ws_stat_cd                   in     varchar2  default hr_api.g_varchar2
  ,p_auto_asnd_dt                 in     date      default hr_api.g_date
  ,p_cbr_elig_perd_strt_dt        in     date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt         in     date      default hr_api.g_date
  ,p_lee_rsn_id                   in     number    default hr_api.g_number
  ,p_enrt_perd_id                 in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pel_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
end ben_pil_elctbl_chc_popl_swi;

 

/
