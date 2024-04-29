--------------------------------------------------------
--  DDL for Package BEN_PIL_ELCTBL_CHC_POPL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ELCTBL_CHC_POPL_API" AUTHID CURRENT_USER as
/* $Header: bepelapi.pkh 120.1 2007/05/13 23:05:21 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Pil_Elctbl_chc_Popl >------------------------|
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
--   p_dflt_enrt_dt                 No   date
--   p_dflt_asnd_dt                 No   date
--   p_elcns_made_dt                No   date
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_enrt_perd_end_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_procg_end_dt                 No   date
--   p_pil_elctbl_popl_stat_cd      No   varchar2
--   p_acty_ref_perd_cd             No   varchar2
--   p_uom                          No   varchar2
--   p_comments                          No   varchar2
--   p_mgr_ovrid_dt                          No   date
--   p_ws_mgr_id                          No   number
--   p_mgr_ovrid_person_id                          No   number
--   p_assignment_id                          No   number
--cwb
--  p_bdgt_acc_cd                   No    varchar2
--  p_pop_cd                        No    varchar2
--  p_bdgt_due_dt                   No    date
--  p_bdgt_export_flag              No    varchar2
--  p_bdgt_iss_dt                   No    date
--  p_bdgt_stat_cd                  No    varchar2
--  p_ws_acc_cd                     No    varchar2
--  p_ws_due_dt                     No    date
--  p_ws_export_flag                No    varchar2
--  p_ws_iss_dt                     No    date
--  p_ws_stat_cd                    No    varchar2
  --cwb
--   p_auto_asnd_dt                 No   date
--   p_cbr_elig_perd_strt_dt        No   date
--   p_cbr_elig_perd_end_dt         No   date
--   p_lee_rsn_id                   No   number
--   p_enrt_perd_id                 No   number
--   p_per_in_ler_id                Yes  number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_pel_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pel_attribute1               No   varchar2  Descriptive Flexfield
--   p_pel_attribute2               No   varchar2  Descriptive Flexfield
--   p_pel_attribute3               No   varchar2  Descriptive Flexfield
--   p_pel_attribute4               No   varchar2  Descriptive Flexfield
--   p_pel_attribute5               No   varchar2  Descriptive Flexfield
--   p_pel_attribute6               No   varchar2  Descriptive Flexfield
--   p_pel_attribute7               No   varchar2  Descriptive Flexfield
--   p_pel_attribute8               No   varchar2  Descriptive Flexfield
--   p_pel_attribute9               No   varchar2  Descriptive Flexfield
--   p_pel_attribute10              No   varchar2  Descriptive Flexfield
--   p_pel_attribute11              No   varchar2  Descriptive Flexfield
--   p_pel_attribute12              No   varchar2  Descriptive Flexfield
--   p_pel_attribute13              No   varchar2  Descriptive Flexfield
--   p_pel_attribute14              No   varchar2  Descriptive Flexfield
--   p_pel_attribute15              No   varchar2  Descriptive Flexfield
--   p_pel_attribute16              No   varchar2  Descriptive Flexfield
--   p_pel_attribute17              No   varchar2  Descriptive Flexfield
--   p_pel_attribute18              No   varchar2  Descriptive Flexfield
--   p_pel_attribute19              No   varchar2  Descriptive Flexfield
--   p_pel_attribute20              No   varchar2  Descriptive Flexfield
--   p_pel_attribute21              No   varchar2  Descriptive Flexfield
--   p_pel_attribute22              No   varchar2  Descriptive Flexfield
--   p_pel_attribute23              No   varchar2  Descriptive Flexfield
--   p_pel_attribute24              No   varchar2  Descriptive Flexfield
--   p_pel_attribute25              No   varchar2  Descriptive Flexfield
--   p_pel_attribute26              No   varchar2  Descriptive Flexfield
--   p_pel_attribute27              No   varchar2  Descriptive Flexfield
--   p_pel_attribute28              No   varchar2  Descriptive Flexfield
--   p_pel_attribute29              No   varchar2  Descriptive Flexfield
--   p_pel_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date           Yes  date      Session Date.
--   p_defer_deenrol_flag           No varchar2
--   p_deenrol_made_dt              No date
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pil_elctbl_chc_popl_id       Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Pil_Elctbl_chc_Popl
(
   p_validate                       in boolean    default false
  ,p_pil_elctbl_chc_popl_id         out nocopy number
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dflt_asnd_dt                   in  date      default null
  ,p_elcns_made_dt                  in  date      default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_pil_elctbl_popl_stat_cd        in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_comments                            in  varchar2  default null
  ,p_mgr_ovrid_dt                            in  date  default null
  ,p_ws_mgr_id                            in  number  default null
  ,p_mgr_ovrid_person_id                            in  number  default null
  ,p_assignment_id                            in  number  default null
  --cwb
  ,p_bdgt_acc_cd                    in varchar2         default null
  ,p_pop_cd                         in varchar2         default null
  ,p_bdgt_due_dt                    in date             default null
  ,p_bdgt_export_flag               in varchar2         default 'N'
  ,p_bdgt_iss_dt                    in date             default null
  ,p_bdgt_stat_cd                   in varchar2         default null
  ,p_ws_acc_cd                      in varchar2         default null
  ,p_ws_due_dt                      in date             default null
  ,p_ws_export_flag                 in varchar2         default 'N'
  ,p_ws_iss_dt                      in date             default null
  ,p_ws_stat_cd                     in varchar2         default null
  --cwb
  ,p_reinstate_cd                   in varchar2   default null
  ,p_reinstate_ovrdn_cd             in varchar2   default null
  ,p_auto_asnd_dt                   in  date      default null
  ,p_cbr_elig_perd_strt_dt          in  date      default null
  ,p_cbr_elig_perd_end_dt           in  date      default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pel_attribute_category         in  varchar2  default null
  ,p_pel_attribute1                 in  varchar2  default null
  ,p_pel_attribute2                 in  varchar2  default null
  ,p_pel_attribute3                 in  varchar2  default null
  ,p_pel_attribute4                 in  varchar2  default null
  ,p_pel_attribute5                 in  varchar2  default null
  ,p_pel_attribute6                 in  varchar2  default null
  ,p_pel_attribute7                 in  varchar2  default null
  ,p_pel_attribute8                 in  varchar2  default null
  ,p_pel_attribute9                 in  varchar2  default null
  ,p_pel_attribute10                in  varchar2  default null
  ,p_pel_attribute11                in  varchar2  default null
  ,p_pel_attribute12                in  varchar2  default null
  ,p_pel_attribute13                in  varchar2  default null
  ,p_pel_attribute14                in  varchar2  default null
  ,p_pel_attribute15                in  varchar2  default null
  ,p_pel_attribute16                in  varchar2  default null
  ,p_pel_attribute17                in  varchar2  default null
  ,p_pel_attribute18                in  varchar2  default null
  ,p_pel_attribute19                in  varchar2  default null
  ,p_pel_attribute20                in  varchar2  default null
  ,p_pel_attribute21                in  varchar2  default null
  ,p_pel_attribute22                in  varchar2  default null
  ,p_pel_attribute23                in  varchar2  default null
  ,p_pel_attribute24                in  varchar2  default null
  ,p_pel_attribute25                in  varchar2  default null
  ,p_pel_attribute26                in  varchar2  default null
  ,p_pel_attribute27                in  varchar2  default null
  ,p_pel_attribute28                in  varchar2  default null
  ,p_pel_attribute29                in  varchar2  default null
  ,p_pel_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_defer_deenrol_flag             in varchar2   default 'N'
  ,p_deenrol_made_dt                in date       default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Pil_Elctbl_chc_Popl >------------------------|
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
--   p_pil_elctbl_chc_popl_id       Yes  number    PK of record
--   p_dflt_enrt_dt                 No   date
--   p_dflt_asnd_dt                 No   date
--   p_elcns_made_dt                No   date
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_enrt_perd_end_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_procg_end_dt                 No   date
--   p_pil_elctbl_popl_stat_cd      No   varchar2
--   p_acty_ref_perd_cd             No   varchar2
--   p_uom                          No   varchar2
--   p_comments                          No   varchar2
--   p_mgr_ovrid_dt                          No   date
--   p_ws_mgr_id                          No   number
--   p_mgr_ovrid_person_id                          No   number
--   p_assignment_id                          No   number
--cwb
--  p_bdgt_acc_cd                   No    varchar2
--  p_pop_cd                        No    varchar2
--  p_bdgt_due_dt                   No    date
--  p_bdgt_export_flag              No    varchar2
--  p_bdgt_iss_dt                   No    date
--  p_bdgt_stat_cd                  No    varchar2
--  p_ws_acc_cd                     No    varchar2
--  p_ws_due_dt                     No    date
--  p_ws_export_flag                No    varchar2
--  p_ws_iss_dt                     No    date
--  p_ws_stat_cd                    No    varchar2
--cwb
--   p_auto_asnd_dt                 No   date
--   p_cbr_elig_perd_strt_dt        No   date
--   p_cbr_elig_perd_end_dt         No   date
--   p_lee_rsn_id                   No   number
--   p_enrt_perd_id                 No   number
--   p_per_in_ler_id                Yes  number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_pel_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pel_attribute1               No   varchar2  Descriptive Flexfield
--   p_pel_attribute2               No   varchar2  Descriptive Flexfield
--   p_pel_attribute3               No   varchar2  Descriptive Flexfield
--   p_pel_attribute4               No   varchar2  Descriptive Flexfield
--   p_pel_attribute5               No   varchar2  Descriptive Flexfield
--   p_pel_attribute6               No   varchar2  Descriptive Flexfield
--   p_pel_attribute7               No   varchar2  Descriptive Flexfield
--   p_pel_attribute8               No   varchar2  Descriptive Flexfield
--   p_pel_attribute9               No   varchar2  Descriptive Flexfield
--   p_pel_attribute10              No   varchar2  Descriptive Flexfield
--   p_pel_attribute11              No   varchar2  Descriptive Flexfield
--   p_pel_attribute12              No   varchar2  Descriptive Flexfield
--   p_pel_attribute13              No   varchar2  Descriptive Flexfield
--   p_pel_attribute14              No   varchar2  Descriptive Flexfield
--   p_pel_attribute15              No   varchar2  Descriptive Flexfield
--   p_pel_attribute16              No   varchar2  Descriptive Flexfield
--   p_pel_attribute17              No   varchar2  Descriptive Flexfield
--   p_pel_attribute18              No   varchar2  Descriptive Flexfield
--   p_pel_attribute19              No   varchar2  Descriptive Flexfield
--   p_pel_attribute20              No   varchar2  Descriptive Flexfield
--   p_pel_attribute21              No   varchar2  Descriptive Flexfield
--   p_pel_attribute22              No   varchar2  Descriptive Flexfield
--   p_pel_attribute23              No   varchar2  Descriptive Flexfield
--   p_pel_attribute24              No   varchar2  Descriptive Flexfield
--   p_pel_attribute25              No   varchar2  Descriptive Flexfield
--   p_pel_attribute26              No   varchar2  Descriptive Flexfield
--   p_pel_attribute27              No   varchar2  Descriptive Flexfield
--   p_pel_attribute28              No   varchar2  Descriptive Flexfield
--   p_pel_attribute29              No   varchar2  Descriptive Flexfield
--   p_pel_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date          Yes  date       Session Date.
--   p_defer_deenrol_flag           No   varchar2
--   p_deenrol_made_dt              No   date
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
procedure update_Pil_Elctbl_chc_Popl
  (
   p_validate                       in boolean    default false
  ,p_pil_elctbl_chc_popl_id         in  number
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dflt_asnd_dt                   in  date      default hr_api.g_date
  ,p_elcns_made_dt                  in  date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_pil_elctbl_popl_stat_cd        in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_comments                            in  varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                            in  date  default hr_api.g_date
  ,p_ws_mgr_id                            in  number  default hr_api.g_number
  ,p_mgr_ovrid_person_id                            in  number  default hr_api.g_number
  ,p_assignment_id                            in  number  default hr_api.g_number
  --cwb
  ,p_bdgt_acc_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pop_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_bdgt_due_dt                    in  date      default hr_api.g_date
  ,p_bdgt_export_flag               in  varchar2  default hr_api.g_varchar2
  ,p_bdgt_iss_dt                    in  date      default hr_api.g_date
  ,p_bdgt_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ws_acc_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ws_due_dt                      in  date      default hr_api.g_date
  ,p_ws_export_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_ws_iss_dt                      in  date      default hr_api.g_date
  ,p_ws_stat_cd                     in  varchar2  default hr_api.g_varchar2
  --cwb
  ,p_reinstate_cd                   in varchar2   default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd             in varchar2   default hr_api.g_varchar2
  ,p_auto_asnd_dt                   in  date      default hr_api.g_date
  ,p_cbr_elig_perd_strt_dt          in  date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt           in  date      default hr_api.g_date
  ,p_lee_rsn_id                     in  number    default hr_api.g_number
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pel_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_defer_deenrol_flag             in varchar2   default hr_api.g_varchar2
  ,p_deenrol_made_dt                in date       default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Pil_Elctbl_chc_Popl >------------------------|
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
--   p_pil_elctbl_chc_popl_id       Yes  number    PK of record
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
procedure delete_Pil_Elctbl_chc_Popl
  (
   p_validate                       in boolean        default false
  ,p_pil_elctbl_chc_popl_id         in  number
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
--   p_pil_elctbl_chc_popl_id                 Yes  number   PK of record
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
    p_pil_elctbl_chc_popl_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_Pil_Elctbl_chc_Popl_api;

/
