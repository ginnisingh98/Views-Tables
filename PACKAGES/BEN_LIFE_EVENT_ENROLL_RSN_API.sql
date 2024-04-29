--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_ENROLL_RSN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_ENROLL_RSN_API" AUTHID CURRENT_USER as
/* $Header: belenapi.pkh 120.1 2007/05/13 22:54:06 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Life_Event_Enroll_Rsn >------------------------|
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
--   p_popl_enrt_typ_cycl_id        No   number
--   p_ler_id                       No   number
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_dys_aftr_end_to_dflt_num     No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_perd_strt_dt_cd         No   varchar2
--   p_enrt_perd_strt_dt_rl         No   number
--   p_enrt_perd_end_dt_cd          No   varchar2
--   p_enrt_perd_end_dt_rl          No   number
--   p_addl_procg_dys_num           No   number
--   p_dys_no_enrl_not_elig_num     No   number
--   p_dys_no_enrl_cant_enrl_num    No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_enrt_cvg_end_dt_rl           No   number
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_len_attribute_category       No   varchar2  Descriptive Flexfield
--   p_len_attribute1               No   varchar2  Descriptive Flexfield
--   p_len_attribute2               No   varchar2  Descriptive Flexfield
--   p_len_attribute3               No   varchar2  Descriptive Flexfield
--   p_len_attribute4               No   varchar2  Descriptive Flexfield
--   p_len_attribute5               No   varchar2  Descriptive Flexfield
--   p_len_attribute6               No   varchar2  Descriptive Flexfield
--   p_len_attribute7               No   varchar2  Descriptive Flexfield
--   p_len_attribute8               No   varchar2  Descriptive Flexfield
--   p_len_attribute9               No   varchar2  Descriptive Flexfield
--   p_len_attribute10              No   varchar2  Descriptive Flexfield
--   p_len_attribute11              No   varchar2  Descriptive Flexfield
--   p_len_attribute12              No   varchar2  Descriptive Flexfield
--   p_len_attribute13              No   varchar2  Descriptive Flexfield
--   p_len_attribute14              No   varchar2  Descriptive Flexfield
--   p_len_attribute15              No   varchar2  Descriptive Flexfield
--   p_len_attribute16              No   varchar2  Descriptive Flexfield
--   p_len_attribute17              No   varchar2  Descriptive Flexfield
--   p_len_attribute18              No   varchar2  Descriptive Flexfield
--   p_len_attribute19              No   varchar2  Descriptive Flexfield
--   p_len_attribute20              No   varchar2  Descriptive Flexfield
--   p_len_attribute21              No   varchar2  Descriptive Flexfield
--   p_len_attribute22              No   varchar2  Descriptive Flexfield
--   p_len_attribute23              No   varchar2  Descriptive Flexfield
--   p_len_attribute24              No   varchar2  Descriptive Flexfield
--   p_len_attribute25              No   varchar2  Descriptive Flexfield
--   p_len_attribute26              No   varchar2  Descriptive Flexfield
--   p_len_attribute27              No   varchar2  Descriptive Flexfield
--   p_len_attribute28              No   varchar2  Descriptive Flexfield
--   p_len_attribute29              No   varchar2  Descriptive Flexfield
--   p_len_attribute30              No   varchar2  Descriptive Flexfield
--   p_enrt_perd_det_ovrlp_bckdt_cd              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--   p_ENRT_PERD_STRT_DAYS           no  number      Session Date.
--   p_ENRT_PERD_END_DAYS            no  number      Session Date.
--   p_DEFER_DEENROL_FLAG         in varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_lee_rsn_id                   Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Life_Event_Enroll_Rsn
(
   p_validate                       in boolean    default false
  ,p_lee_rsn_id                     out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_dys_aftr_end_to_dflt_num       in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_strt_dt_cd           in  varchar2  default null
  ,p_enrt_perd_strt_dt_rl           in  number    default null
  ,p_enrt_perd_end_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt_rl            in  number    default null
  ,p_addl_procg_dys_num             in  number    default null
  ,p_dys_no_enrl_not_elig_num       in  number    default null
  ,p_dys_no_enrl_cant_enrl_num      in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_len_attribute_category         in  varchar2  default null
  ,p_len_attribute1                 in  varchar2  default null
  ,p_len_attribute2                 in  varchar2  default null
  ,p_len_attribute3                 in  varchar2  default null
  ,p_len_attribute4                 in  varchar2  default null
  ,p_len_attribute5                 in  varchar2  default null
  ,p_len_attribute6                 in  varchar2  default null
  ,p_len_attribute7                 in  varchar2  default null
  ,p_len_attribute8                 in  varchar2  default null
  ,p_len_attribute9                 in  varchar2  default null
  ,p_len_attribute10                in  varchar2  default null
  ,p_len_attribute11                in  varchar2  default null
  ,p_len_attribute12                in  varchar2  default null
  ,p_len_attribute13                in  varchar2  default null
  ,p_len_attribute14                in  varchar2  default null
  ,p_len_attribute15                in  varchar2  default null
  ,p_len_attribute16                in  varchar2  default null
  ,p_len_attribute17                in  varchar2  default null
  ,p_len_attribute18                in  varchar2  default null
  ,p_len_attribute19                in  varchar2  default null
  ,p_len_attribute20                in  varchar2  default null
  ,p_len_attribute21                in  varchar2  default null
  ,p_len_attribute22                in  varchar2  default null
  ,p_len_attribute23                in  varchar2  default null
  ,p_len_attribute24                in  varchar2  default null
  ,p_len_attribute25                in  varchar2  default null
  ,p_len_attribute26                in  varchar2  default null
  ,p_len_attribute27                in  varchar2  default null
  ,p_len_attribute28                in  varchar2  default null
  ,p_len_attribute29                in  varchar2  default null
  ,p_len_attribute30                in  varchar2  default null
  ,p_enrt_perd_det_ovrlp_bckdt_cd   in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_reinstate_cd			        in varchar2	  default null
  ,p_reinstate_ovrdn_cd		        in varchar2	default null
  ,p_ENRT_PERD_STRT_DAYS 	        in number	default null
  ,p_ENRT_PERD_END_DAYS 	        in number	default null
  ,p_defer_deenrol_flag             in varchar2       default 'N'
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Life_Event_Enroll_Rsn >------------------------|
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
--   p_lee_rsn_id                   Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_popl_enrt_typ_cycl_id        No   number
--   p_ler_id                       No   number
--   p_cls_enrt_dt_to_use_cd        No   varchar2
--   p_dys_aftr_end_to_dflt_num     No   number
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_perd_strt_dt_cd         No   varchar2
--   p_enrt_perd_strt_dt_rl         No   number
--   p_enrt_perd_end_dt_cd          No   varchar2
--   p_enrt_perd_end_dt_rl          No   number
--   p_addl_procg_dys_num           No   number
--   p_dys_no_enrl_not_elig_num     No   number
--   p_dys_no_enrl_cant_enrl_num    No   number
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_rt_strt_dt_rl                No   number
--   p_enrt_cvg_end_dt_rl           No   number
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_len_attribute_category       No   varchar2  Descriptive Flexfield
--   p_len_attribute1               No   varchar2  Descriptive Flexfield
--   p_len_attribute2               No   varchar2  Descriptive Flexfield
--   p_len_attribute3               No   varchar2  Descriptive Flexfield
--   p_len_attribute4               No   varchar2  Descriptive Flexfield
--   p_len_attribute5               No   varchar2  Descriptive Flexfield
--   p_len_attribute6               No   varchar2  Descriptive Flexfield
--   p_len_attribute7               No   varchar2  Descriptive Flexfield
--   p_len_attribute8               No   varchar2  Descriptive Flexfield
--   p_len_attribute9               No   varchar2  Descriptive Flexfield
--   p_len_attribute10              No   varchar2  Descriptive Flexfield
--   p_len_attribute11              No   varchar2  Descriptive Flexfield
--   p_len_attribute12              No   varchar2  Descriptive Flexfield
--   p_len_attribute13              No   varchar2  Descriptive Flexfield
--   p_len_attribute14              No   varchar2  Descriptive Flexfield
--   p_len_attribute15              No   varchar2  Descriptive Flexfield
--   p_len_attribute16              No   varchar2  Descriptive Flexfield
--   p_len_attribute17              No   varchar2  Descriptive Flexfield
--   p_len_attribute18              No   varchar2  Descriptive Flexfield
--   p_len_attribute19              No   varchar2  Descriptive Flexfield
--   p_len_attribute20              No   varchar2  Descriptive Flexfield
--   p_len_attribute21              No   varchar2  Descriptive Flexfield
--   p_len_attribute22              No   varchar2  Descriptive Flexfield
--   p_len_attribute23              No   varchar2  Descriptive Flexfield
--   p_len_attribute24              No   varchar2  Descriptive Flexfield
--   p_len_attribute25              No   varchar2  Descriptive Flexfield
--   p_len_attribute26              No   varchar2  Descriptive Flexfield
--   p_len_attribute27              No   varchar2  Descriptive Flexfield
--   p_len_attribute28              No   varchar2  Descriptive Flexfield
--   p_len_attribute29              No   varchar2  Descriptive Flexfield
--   p_len_attribute30              No   varchar2  Descriptive Flexfield
--   p_enrt_perd_det_ovrlp_bckdt_cd              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_ENRT_PERD_STRT_DAYS          no  number
--   p_ENRT_PERD_END_DAYS          no  number
--   p_DEFER_DEENROL_FLAG         in varchar2       default 'N'

--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_Life_Event_Enroll_Rsn
  (
   p_validate                       in boolean    default false
  ,p_lee_rsn_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_popl_enrt_typ_cycl_id          in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_dys_aftr_end_to_dflt_num       in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_strt_dt_cd           in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_strt_dt_rl           in  number    default hr_api.g_number
  ,p_enrt_perd_end_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt_rl            in  number    default hr_api.g_number
  ,p_addl_procg_dys_num             in  number    default hr_api.g_number
  ,p_dys_no_enrl_not_elig_num       in  number    default hr_api.g_number
  ,p_dys_no_enrl_cant_enrl_num      in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_len_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_reinstate_cd			in varchar2 default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd		in varchar2 default hr_api.g_varchar2
  ,p_ENRT_PERD_STRT_DAYS       	in number  default hr_api.g_number
  ,p_ENRT_PERD_END_DAYS       	in number  default hr_api.g_number
  ,p_defer_deenrol_flag         in varchar2       default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Life_Event_Enroll_Rsn >------------------------|
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
--   p_lee_rsn_id                   Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_Life_Event_Enroll_Rsn
  (
   p_validate                       in boolean        default false
  ,p_lee_rsn_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
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
--   p_lee_rsn_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
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
    p_lee_rsn_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Life_Event_Enroll_Rsn_api;

/
