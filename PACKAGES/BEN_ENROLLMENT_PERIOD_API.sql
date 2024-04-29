--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_PERIOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_PERIOD_API" AUTHID CURRENT_USER as
/* $Header: beenpapi.pkh 120.1 2007/05/13 22:49:18 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Enrollment_Period >------------------------|
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
--   p_business_group_id            Yes  number    Business Group of Record
--   p_yr_perd_id                   Yes  number
--   p_popl_enrt_typ_cycl_id        Yes  number
--   p_end_dt                       Yes  date
--   p_strt_dt                      Yes  date
--   p_asnd_lf_evt_dt               Yes  date
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_dflt_enrt_dt                 No   date
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_cvg_end_dt_rl           No   number
--   p_procg_end_dt                 Yes  date
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_bdgt_upd_strt_dt             No   date
--   p_bdgt_upd_end_dt              No   date
--   p_ws_upd_strt_dt               No   date
--   p_ws_upd_end_dt                No   date
--   p_dflt_ws_acc_cd               No   varchar2
--   p_prsvr_bdgt_cd                No   varchar2
--   p_uses_bdgt_flag               Yes   varchar2
--   p_auto_distr_flag              Yes   varchar2
--   p_hrchy_to_use_cd              No   varchar2
--   p_pos_structure_version_id        No   number
--   p_emp_interview_type_cd        No   varchar2
--   p_wthn_yr_perd_id              No   number
--   p_ler_id                       No   number
--   p_enp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_enp_attribute1               No   varchar2  Descriptive Flexfield
--   p_enp_attribute2               No   varchar2  Descriptive Flexfield
--   p_enp_attribute3               No   varchar2  Descriptive Flexfield
--   p_enp_attribute4               No   varchar2  Descriptive Flexfield
--   p_enp_attribute5               No   varchar2  Descriptive Flexfield
--   p_enp_attribute6               No   varchar2  Descriptive Flexfield
--   p_enp_attribute7               No   varchar2  Descriptive Flexfield
--   p_enp_attribute8               No   varchar2  Descriptive Flexfield
--   p_enp_attribute9               No   varchar2  Descriptive Flexfield
--   p_enp_attribute10              No   varchar2  Descriptive Flexfield
--   p_enp_attribute11              No   varchar2  Descriptive Flexfield
--   p_enp_attribute12              No   varchar2  Descriptive Flexfield
--   p_enp_attribute13              No   varchar2  Descriptive Flexfield
--   p_enp_attribute14              No   varchar2  Descriptive Flexfield
--   p_enp_attribute15              No   varchar2  Descriptive Flexfield
--   p_enp_attribute16              No   varchar2  Descriptive Flexfield
--   p_enp_attribute17              No   varchar2  Descriptive Flexfield
--   p_enp_attribute18              No   varchar2  Descriptive Flexfield
--   p_enp_attribute19              No   varchar2  Descriptive Flexfield
--   p_enp_attribute20              No   varchar2  Descriptive Flexfield
--   p_enp_attribute21              No   varchar2  Descriptive Flexfield
--   p_enp_attribute22              No   varchar2  Descriptive Flexfield
--   p_enp_attribute23              No   varchar2  Descriptive Flexfield
--   p_enp_attribute24              No   varchar2  Descriptive Flexfield
--   p_enp_attribute25              No   varchar2  Descriptive Flexfield
--   p_enp_attribute26              No   varchar2  Descriptive Flexfield
--   p_enp_attribute27              No   varchar2  Descriptive Flexfield
--   p_enp_attribute28              No   varchar2  Descriptive Flexfield
--   p_enp_attribute29              No   varchar2  Descriptive Flexfield
--   p_enp_attribute30              No   varchar2  Descriptive Flexfield
--   p_enrt_perd_det_ovrlp_bckdt_cd              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--   p_DEFER_DEENROL_FLAG         in varchar2       default 'N'
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_enrt_perd_id                 Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Enrollment_Period
(
   p_validate                       in boolean    default false
  ,p_enrt_perd_id                   out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_end_dt                         in  date      default null
  ,p_strt_dt                        in  date      default null
  ,p_asnd_lf_evt_dt                 in  date      default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_procg_end_dt                   in  date      default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_bdgt_upd_strt_dt               in  date      default null
  ,p_bdgt_upd_end_dt                in  date      default null
  ,p_ws_upd_strt_dt                 in  date      default null
  ,p_ws_upd_end_dt                  in  date      default null
  ,p_dflt_ws_acc_cd                 in  varchar2  default null
  ,p_prsvr_bdgt_cd                  in  varchar2  default null
  ,p_uses_bdgt_flag                 in  varchar2  default 'N'
  ,p_auto_distr_flag                in  varchar2  default 'N'
  ,p_hrchy_to_use_cd                in  varchar2  default null
  ,p_pos_structure_version_id          in  number    default null
  ,p_emp_interview_type_cd          in  varchar2  default null
  ,p_wthn_yr_perd_id                in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_perf_revw_strt_dt              in  date      default null
  ,p_asg_updt_eff_date              in  date      default null
  ,p_enp_attribute_category         in  varchar2  default null
  ,p_enp_attribute1                 in  varchar2  default null
  ,p_enp_attribute2                 in  varchar2  default null
  ,p_enp_attribute3                 in  varchar2  default null
  ,p_enp_attribute4                 in  varchar2  default null
  ,p_enp_attribute5                 in  varchar2  default null
  ,p_enp_attribute6                 in  varchar2  default null
  ,p_enp_attribute7                 in  varchar2  default null
  ,p_enp_attribute8                 in  varchar2  default null
  ,p_enp_attribute9                 in  varchar2  default null
  ,p_enp_attribute10                in  varchar2  default null
  ,p_enp_attribute11                in  varchar2  default null
  ,p_enp_attribute12                in  varchar2  default null
  ,p_enp_attribute13                in  varchar2  default null
  ,p_enp_attribute14                in  varchar2  default null
  ,p_enp_attribute15                in  varchar2  default null
  ,p_enp_attribute16                in  varchar2  default null
  ,p_enp_attribute17                in  varchar2  default null
  ,p_enp_attribute18                in  varchar2  default null
  ,p_enp_attribute19                in  varchar2  default null
  ,p_enp_attribute20                in  varchar2  default null
  ,p_enp_attribute21                in  varchar2  default null
  ,p_enp_attribute22                in  varchar2  default null
  ,p_enp_attribute23                in  varchar2  default null
  ,p_enp_attribute24                in  varchar2  default null
  ,p_enp_attribute25                in  varchar2  default null
  ,p_enp_attribute26                in  varchar2  default null
  ,p_enp_attribute27                in  varchar2  default null
  ,p_enp_attribute28                in  varchar2  default null
  ,p_enp_attribute29                in  varchar2  default null
  ,p_enp_attribute30                in  varchar2  default null
  ,p_enrt_perd_det_ovrlp_bckdt_cd   in  varchar2  default null
   --cwb
  ,p_data_freeze_date               in  date      default null
  ,p_Sal_chg_reason_cd              in  varchar2  default null
  ,p_Approval_mode_cd               in  varchar2  default null
  ,p_hrchy_ame_trn_cd               in  varchar2  default null
  ,p_hrchy_rl                       in  number    default null
  ,p_hrchy_ame_app_id               in  number    default null
  --
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
  ,p_reinstate_cd		in varchar2	default null
  ,p_reinstate_ovrdn_cd	in varchar2	default null
  ,p_DEFER_DEENROL_FLAG         in varchar2       default 'N'
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Enrollment_Period >------------------------|
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
--   p_enrt_perd_id                 Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_yr_perd_id                   Yes  number
--   p_popl_enrt_typ_cycl_id        Yes  number
--   p_end_dt                       Yes  date
--   p_strt_dt                      Yes  date
--   p_asnd_lf_evt_dt               Yes  date
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_dflt_enrt_dt                 No   date
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_enrt_cvg_end_dt_rl           No   number
--   p_procg_end_dt                 Yes  date
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_bdgt_upd_strt_dt             No   date
--   p_bdgt_upd_end_dt              No   date
--   p_ws_upd_strt_dt               No   date
--   p_ws_upd_end_dt                No   date
--   p_dflt_ws_acc_cd               No   varchar2
--   p_prsvr_bdgt_cd                No   varchar2
--   p_uses_bdgt_flag               No   varchar2
--   p_auto_distr_flag              No   varchar2
--   p_hrchy_to_use_cd              No   varchar2
--   p_pos_structure_version_id        No   number
--   p_emp_interview_type_cd        No   varchar2
--   p_wthn_yr_perd_id              No   number
--   p_ler_id                       No   number
--   p_enp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_enp_attribute1               No   varchar2  Descriptive Flexfield
--   p_enp_attribute2               No   varchar2  Descriptive Flexfield
--   p_enp_attribute3               No   varchar2  Descriptive Flexfield
--   p_enp_attribute4               No   varchar2  Descriptive Flexfield
--   p_enp_attribute5               No   varchar2  Descriptive Flexfield
--   p_enp_attribute6               No   varchar2  Descriptive Flexfield
--   p_enp_attribute7               No   varchar2  Descriptive Flexfield
--   p_enp_attribute8               No   varchar2  Descriptive Flexfield
--   p_enp_attribute9               No   varchar2  Descriptive Flexfield
--   p_enp_attribute10              No   varchar2  Descriptive Flexfield
--   p_enp_attribute11              No   varchar2  Descriptive Flexfield
--   p_enp_attribute12              No   varchar2  Descriptive Flexfield
--   p_enp_attribute13              No   varchar2  Descriptive Flexfield
--   p_enp_attribute14              No   varchar2  Descriptive Flexfield
--   p_enp_attribute15              No   varchar2  Descriptive Flexfield
--   p_enp_attribute16              No   varchar2  Descriptive Flexfield
--   p_enp_attribute17              No   varchar2  Descriptive Flexfield
--   p_enp_attribute18              No   varchar2  Descriptive Flexfield
--   p_enp_attribute19              No   varchar2  Descriptive Flexfield
--   p_enp_attribute20              No   varchar2  Descriptive Flexfield
--   p_enp_attribute21              No   varchar2  Descriptive Flexfield
--   p_enp_attribute22              No   varchar2  Descriptive Flexfield
--   p_enp_attribute23              No   varchar2  Descriptive Flexfield
--   p_enp_attribute24              No   varchar2  Descriptive Flexfield
--   p_enp_attribute25              No   varchar2  Descriptive Flexfield
--   p_enp_attribute26              No   varchar2  Descriptive Flexfield
--   p_enp_attribute27              No   varchar2  Descriptive Flexfield
--   p_enp_attribute28              No   varchar2  Descriptive Flexfield
--   p_enp_attribute29              No   varchar2  Descriptive Flexfield
--   p_enp_attribute30              No   varchar2  Descriptive Flexfield
--   p_enrt_perd_det_ovrlp_bckdt_cd No   varchar2  Descriptive Flexfield
     --cwb
--p_data_freeze_date               in  date      default null
--p_Sal_chg_reason_cd              in  varchar2  default null
--p_Approval_mode_cd               in  varchar2  default null
--p_hrchy_ame_trn_cd               in  varchar2  default null
--p_hrchy_rl                       in  number    default null
--p_hrchy_ame_app_id               in  number    default null
--p_DEFER_DEENROL_FLAG             in varchar2       default 'N'

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
procedure update_Enrollment_Period
  (
   p_validate                       in boolean    default false
  ,p_enrt_perd_id                   in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_popl_enrt_typ_cycl_id          in  number    default hr_api.g_number
  ,p_end_dt                         in  date      default hr_api.g_date
  ,p_strt_dt                        in  date      default hr_api.g_date
  ,p_asnd_lf_evt_dt                 in  date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_bdgt_upd_strt_dt               in  date      default hr_api.g_date
  ,p_bdgt_upd_end_dt                in  date      default hr_api.g_date
  ,p_ws_upd_strt_dt                 in  date      default hr_api.g_date
  ,p_ws_upd_end_dt                  in  date      default hr_api.g_date
  ,p_dflt_ws_acc_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_prsvr_bdgt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_uses_bdgt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_auto_distr_flag                in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_to_use_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pos_structure_version_id          in  number    default hr_api.g_number
  ,p_emp_interview_type_cd          in  varchar2  default hr_api.g_varchar2
  ,p_wthn_yr_perd_id                in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_perf_revw_strt_dt              in  date      default hr_api.g_date
  ,p_asg_updt_eff_date              in  date      default hr_api.g_date
  ,p_enp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd   in  varchar2  default hr_api.g_varchar2
  --cwb
  ,p_data_freeze_date               in  date      default hr_api.g_date
  ,p_Sal_chg_reason_cd              in  varchar2  default hr_api.g_varchar2
  ,p_Approval_mode_cd               in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_ame_trn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_rl                       in  number    default hr_api.g_number
  ,p_hrchy_ame_app_id               in  number    default hr_api.g_number
  --
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_reinstate_cd		in varchar2	default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd	in varchar2	default hr_api.g_varchar2
  ,p_DEFER_DEENROL_FLAG             in varchar2       default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Enrollment_Period >------------------------|
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
--   p_enrt_perd_id                 Yes  number    PK of record
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
procedure delete_Enrollment_Period
  (
   p_validate                       in boolean        default false
  ,p_enrt_perd_id                   in  number
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
--   p_enrt_perd_id                 Yes  number   PK of record
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
    p_enrt_perd_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_Enrollment_Period_api;

/
