--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_REASON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_REASON_API" AUTHID CURRENT_USER as
/* $Header: belerapi.pkh 120.1 2006/11/03 10:37:41 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Life_Event_Reason >----------------------|
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
--   p_name                         Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_typ_cd                       No   varchar2
--   p_lf_evt_oper_cd               No   varchar2
--   p_short_name	            No   varchar2
--   p_short_code       	    No   varchar2
--   p_ptnl_ler_trtmt_cd            No   varchar2
--   p_ck_rltd_per_elig_flag        Yes  varchar2
--   p_ler_eval_rl                  No   number
--   p_cm_aply_flag                 Yes  varchar2
--   p_ovridg_le_flag               No   varchar2
--   p_qualg_evt_flag               No   varchar2
--   p_whn_to_prcs_cd               No   varchar2
--   p_desc_txt                     No   varchar2
--   p_ss_pcp_disp_cd               No   varchar2
--   p_ler_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ler_attribute1               No   varchar2  Descriptive Flexfield
--   p_ler_attribute2               No   varchar2  Descriptive Flexfield
--   p_ler_attribute3               No   varchar2  Descriptive Flexfield
--   p_ler_attribute4               No   varchar2  Descriptive Flexfield
--   p_ler_attribute5               No   varchar2  Descriptive Flexfield
--   p_ler_attribute6               No   varchar2  Descriptive Flexfield
--   p_ler_attribute7               No   varchar2  Descriptive Flexfield
--   p_ler_attribute8               No   varchar2  Descriptive Flexfield
--   p_ler_attribute9               No   varchar2  Descriptive Flexfield
--   p_ler_attribute10              No   varchar2  Descriptive Flexfield
--   p_ler_attribute11              No   varchar2  Descriptive Flexfield
--   p_ler_attribute12              No   varchar2  Descriptive Flexfield
--   p_ler_attribute13              No   varchar2  Descriptive Flexfield
--   p_ler_attribute14              No   varchar2  Descriptive Flexfield
--   p_ler_attribute15              No   varchar2  Descriptive Flexfield
--   p_ler_attribute16              No   varchar2  Descriptive Flexfield
--   p_ler_attribute17              No   varchar2  Descriptive Flexfield
--   p_ler_attribute18              No   varchar2  Descriptive Flexfield
--   p_ler_attribute19              No   varchar2  Descriptive Flexfield
--   p_ler_attribute20              No   varchar2  Descriptive Flexfield
--   p_ler_attribute21              No   varchar2  Descriptive Flexfield
--   p_ler_attribute22              No   varchar2  Descriptive Flexfield
--   p_ler_attribute23              No   varchar2  Descriptive Flexfield
--   p_ler_attribute24              No   varchar2  Descriptive Flexfield
--   p_ler_attribute25              No   varchar2  Descriptive Flexfield
--   p_ler_attribute26              No   varchar2  Descriptive Flexfield
--   p_ler_attribute27              No   varchar2  Descriptive Flexfield
--   p_ler_attribute28              No   varchar2  Descriptive Flexfield
--   p_ler_attribute29              No   varchar2  Descriptive Flexfield
--   p_ler_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ler_id                       Yes  number    PK of record
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
procedure create_Life_Event_Reason
(
   p_validate                       in boolean    default false
  ,p_ler_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_lf_evt_oper_cd                 in  varchar2  default null
  ,p_short_name                 in  varchar2  default null
  ,p_short_code                 in  varchar2  default null
  ,p_ptnl_ler_trtmt_cd              in  varchar2  default null
  ,p_ck_rltd_per_elig_flag          in  varchar2  default null
  ,p_ler_eval_rl                    in  number    default null
  ,p_cm_aply_flag                   in  varchar2  default null
  ,p_ovridg_le_flag                 in  varchar2  default null
  ,p_qualg_evt_flag                 in  varchar2  default null
  ,p_whn_to_prcs_cd                 in  varchar2  default null
  ,p_desc_txt                       in  varchar2  default null
  ,p_tmlns_eval_cd                  in  varchar2  default null
  ,p_tmlns_perd_cd                  in  varchar2  default null
  ,p_tmlns_dys_num                  in  number    default null
  ,p_tmlns_perd_rl                  in  number    default null
  ,p_ocrd_dt_det_cd                 in  varchar2  default null
  ,p_ler_stat_cd                    in  varchar2  default null
  ,p_slctbl_slf_svc_cd              in  varchar2  default null
  ,p_ss_pcp_disp_cd                 in  varchar2  default null
  ,p_ler_attribute_category         in  varchar2  default null
  ,p_ler_attribute1                 in  varchar2  default null
  ,p_ler_attribute2                 in  varchar2  default null
  ,p_ler_attribute3                 in  varchar2  default null
  ,p_ler_attribute4                 in  varchar2  default null
  ,p_ler_attribute5                 in  varchar2  default null
  ,p_ler_attribute6                 in  varchar2  default null
  ,p_ler_attribute7                 in  varchar2  default null
  ,p_ler_attribute8                 in  varchar2  default null
  ,p_ler_attribute9                 in  varchar2  default null
  ,p_ler_attribute10                in  varchar2  default null
  ,p_ler_attribute11                in  varchar2  default null
  ,p_ler_attribute12                in  varchar2  default null
  ,p_ler_attribute13                in  varchar2  default null
  ,p_ler_attribute14                in  varchar2  default null
  ,p_ler_attribute15                in  varchar2  default null
  ,p_ler_attribute16                in  varchar2  default null
  ,p_ler_attribute17                in  varchar2  default null
  ,p_ler_attribute18                in  varchar2  default null
  ,p_ler_attribute19                in  varchar2  default null
  ,p_ler_attribute20                in  varchar2  default null
  ,p_ler_attribute21                in  varchar2  default null
  ,p_ler_attribute22                in  varchar2  default null
  ,p_ler_attribute23                in  varchar2  default null
  ,p_ler_attribute24                in  varchar2  default null
  ,p_ler_attribute25                in  varchar2  default null
  ,p_ler_attribute26                in  varchar2  default null
  ,p_ler_attribute27                in  varchar2  default null
  ,p_ler_attribute28                in  varchar2  default null
  ,p_ler_attribute29                in  varchar2  default null
  ,p_ler_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Life_Event_Reason >------------------------|
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
--   p_ler_id                       Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_typ_cd                       No   varchar2
--   p_lf_evt_oper_cd               No   varchar2
--   p_short_name                   No   varchar2
--   p_short_code                   No   varchar2
--   p_ck_rltd_per_elig_flag        Yes  varchar2
--   p_ler_eval_rl                  No   number
--   p_cm_aply_flag                 Yes  varchar2
--   p_ovridg_le_flag               No   varchar2
--   p_qualg_evt_flag               No   varchar2
--   p_whn_to_prcs_cd               No   varchar2
--   p_desc_txt                     No   varchar2
--   p_ss_pcp_disp_cd               No   varchar2
--   p_ler_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ler_attribute1               No   varchar2  Descriptive Flexfield
--   p_ler_attribute2               No   varchar2  Descriptive Flexfield
--   p_ler_attribute3               No   varchar2  Descriptive Flexfield
--   p_ler_attribute4               No   varchar2  Descriptive Flexfield
--   p_ler_attribute5               No   varchar2  Descriptive Flexfield
--   p_ler_attribute6               No   varchar2  Descriptive Flexfield
--   p_ler_attribute7               No   varchar2  Descriptive Flexfield
--   p_ler_attribute8               No   varchar2  Descriptive Flexfield
--   p_ler_attribute9               No   varchar2  Descriptive Flexfield
--   p_ler_attribute10              No   varchar2  Descriptive Flexfield
--   p_ler_attribute11              No   varchar2  Descriptive Flexfield
--   p_ler_attribute12              No   varchar2  Descriptive Flexfield
--   p_ler_attribute13              No   varchar2  Descriptive Flexfield
--   p_ler_attribute14              No   varchar2  Descriptive Flexfield
--   p_ler_attribute15              No   varchar2  Descriptive Flexfield
--   p_ler_attribute16              No   varchar2  Descriptive Flexfield
--   p_ler_attribute17              No   varchar2  Descriptive Flexfield
--   p_ler_attribute18              No   varchar2  Descriptive Flexfield
--   p_ler_attribute19              No   varchar2  Descriptive Flexfield
--   p_ler_attribute20              No   varchar2  Descriptive Flexfield
--   p_ler_attribute21              No   varchar2  Descriptive Flexfield
--   p_ler_attribute22              No   varchar2  Descriptive Flexfield
--   p_ler_attribute23              No   varchar2  Descriptive Flexfield
--   p_ler_attribute24              No   varchar2  Descriptive Flexfield
--   p_ler_attribute25              No   varchar2  Descriptive Flexfield
--   p_ler_attribute26              No   varchar2  Descriptive Flexfield
--   p_ler_attribute27              No   varchar2  Descriptive Flexfield
--   p_ler_attribute28              No   varchar2  Descriptive Flexfield
--   p_ler_attribute29              No   varchar2  Descriptive Flexfield
--   p_ler_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
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
procedure update_Life_Event_Reason
  (
   p_validate                       in boolean    default false
  ,p_ler_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_lf_evt_oper_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2
  ,p_ptnl_ler_trtmt_cd              in  varchar2  default hr_api.g_varchar2
  ,p_ck_rltd_per_elig_flag          in  varchar2  default hr_api.g_varchar2
  ,p_ler_eval_rl                    in  number    default hr_api.g_number
  ,p_cm_aply_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_ovridg_le_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_qualg_evt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_whn_to_prcs_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_desc_txt                       in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_eval_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_dys_num                  in  number    default hr_api.g_number
  ,p_tmlns_perd_rl                  in  number    default hr_api.g_number
  ,p_ocrd_dt_det_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_slctbl_slf_svc_cd              in  varchar2  default hr_api.g_varchar2
  ,p_ss_pcp_disp_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Life_Event_Reason >------------------------|
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
--   p_ler_id                       Yes  number    PK of record
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
procedure delete_Life_Event_Reason
  (
   p_validate                       in boolean        default false
  ,p_ler_id                         in  number
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
--   p_ler_id                 Yes  number   PK of record
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
    p_ler_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Life_Event_Reason_api;

/
