--------------------------------------------------------
--  DDL for Package BEN_PER_CM_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_CM_PRVDD_API" AUTHID CURRENT_USER as
/* $Header: bepcdapi.pkh 120.0 2005/05/28 10:09:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_PRVDD >---------------------------|
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
--   p_rqstd_flag                   Yes  varchar2
--   p_per_cm_prvdd_stat_cd         No   varchar2
--   p_cm_dlvry_med_cd              No   varchar2
--   p_cm_dlvry_mthd_cd             No   varchar2
--   p_sent_dt                      No   date
--   p_instnc_num                   No   number
--   p_to_be_sent_dt                No   date
--   p_dlvry_instn_txt              No   varchar2
--   p_inspn_rqd_flag               Yes  varchar2
--   p_resnd_rsn_cd                 No   varchar2
--   p_resnd_cmnt_txt               No   varchar2
--   p_per_cm_id                    Yes  number
--   p_address_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcd_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_per_cm_prvdd_id              Yes  number    PK of record
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
procedure create_PER_CM_PRVDD
  (p_validate                       in boolean    default false
  ,p_per_cm_prvdd_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default 'N'
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default null
  ,p_cm_dlvry_med_cd                in  varchar2  default null
  ,p_cm_dlvry_mthd_cd               in  varchar2  default null
  ,p_sent_dt                        in  date      default null
  ,p_instnc_num                     in  number    default null
  ,p_to_be_sent_dt                  in  date      default null
  ,p_dlvry_instn_txt                in  varchar2  default null
  ,p_inspn_rqd_flag                 in  varchar2  default 'N'
  ,p_resnd_rsn_cd                   in  varchar2  default null
  ,p_resnd_cmnt_txt                 in  varchar2  default null
  ,p_per_cm_id                      in  number    default null
  ,p_address_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcd_attribute_category         in  varchar2  default null
  ,p_pcd_attribute1                 in  varchar2  default null
  ,p_pcd_attribute2                 in  varchar2  default null
  ,p_pcd_attribute3                 in  varchar2  default null
  ,p_pcd_attribute4                 in  varchar2  default null
  ,p_pcd_attribute5                 in  varchar2  default null
  ,p_pcd_attribute6                 in  varchar2  default null
  ,p_pcd_attribute7                 in  varchar2  default null
  ,p_pcd_attribute8                 in  varchar2  default null
  ,p_pcd_attribute9                 in  varchar2  default null
  ,p_pcd_attribute10                in  varchar2  default null
  ,p_pcd_attribute11                in  varchar2  default null
  ,p_pcd_attribute12                in  varchar2  default null
  ,p_pcd_attribute13                in  varchar2  default null
  ,p_pcd_attribute14                in  varchar2  default null
  ,p_pcd_attribute15                in  varchar2  default null
  ,p_pcd_attribute16                in  varchar2  default null
  ,p_pcd_attribute17                in  varchar2  default null
  ,p_pcd_attribute18                in  varchar2  default null
  ,p_pcd_attribute19                in  varchar2  default null
  ,p_pcd_attribute20                in  varchar2  default null
  ,p_pcd_attribute21                in  varchar2  default null
  ,p_pcd_attribute22                in  varchar2  default null
  ,p_pcd_attribute23                in  varchar2  default null
  ,p_pcd_attribute24                in  varchar2  default null
  ,p_pcd_attribute25                in  varchar2  default null
  ,p_pcd_attribute26                in  varchar2  default null
  ,p_pcd_attribute27                in  varchar2  default null
  ,p_pcd_attribute28                in  varchar2  default null
  ,p_pcd_attribute29                in  varchar2  default null
  ,p_pcd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_PRVDD_perf >----------------------|
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
--   p_rqstd_flag                   Yes  varchar2
--   p_per_cm_prvdd_stat_cd         No   varchar2
--   p_cm_dlvry_med_cd              No   varchar2
--   p_cm_dlvry_mthd_cd             No   varchar2
--   p_sent_dt                      No   date
--   p_instnc_num                   No   number
--   p_to_be_sent_dt                No   date
--   p_dlvry_instn_txt              No   varchar2
--   p_inspn_rqd_flag               Yes  varchar2
--   p_resnd_rsn_cd                 No   varchar2
--   p_resnd_cmnt_txt               No   varchar2
--   p_per_cm_id                    Yes  number
--   p_address_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcd_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_per_cm_prvdd_id              Yes  number    PK of record
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
procedure create_PER_CM_PRVDD_perf
  (p_validate                       in boolean    default false
  ,p_per_cm_prvdd_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default 'N'
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default null
  ,p_cm_dlvry_med_cd                in  varchar2  default null
  ,p_cm_dlvry_mthd_cd               in  varchar2  default null
  ,p_sent_dt                        in  date      default null
  ,p_instnc_num                     in  number    default null
  ,p_to_be_sent_dt                  in  date      default null
  ,p_dlvry_instn_txt                in  varchar2  default null
  ,p_inspn_rqd_flag                 in  varchar2  default 'N'
  ,p_resnd_rsn_cd                   in  varchar2  default null
  ,p_resnd_cmnt_txt                 in  varchar2  default null
  ,p_per_cm_id                      in  number    default null
  ,p_address_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcd_attribute_category         in  varchar2  default null
  ,p_pcd_attribute1                 in  varchar2  default null
  ,p_pcd_attribute2                 in  varchar2  default null
  ,p_pcd_attribute3                 in  varchar2  default null
  ,p_pcd_attribute4                 in  varchar2  default null
  ,p_pcd_attribute5                 in  varchar2  default null
  ,p_pcd_attribute6                 in  varchar2  default null
  ,p_pcd_attribute7                 in  varchar2  default null
  ,p_pcd_attribute8                 in  varchar2  default null
  ,p_pcd_attribute9                 in  varchar2  default null
  ,p_pcd_attribute10                in  varchar2  default null
  ,p_pcd_attribute11                in  varchar2  default null
  ,p_pcd_attribute12                in  varchar2  default null
  ,p_pcd_attribute13                in  varchar2  default null
  ,p_pcd_attribute14                in  varchar2  default null
  ,p_pcd_attribute15                in  varchar2  default null
  ,p_pcd_attribute16                in  varchar2  default null
  ,p_pcd_attribute17                in  varchar2  default null
  ,p_pcd_attribute18                in  varchar2  default null
  ,p_pcd_attribute19                in  varchar2  default null
  ,p_pcd_attribute20                in  varchar2  default null
  ,p_pcd_attribute21                in  varchar2  default null
  ,p_pcd_attribute22                in  varchar2  default null
  ,p_pcd_attribute23                in  varchar2  default null
  ,p_pcd_attribute24                in  varchar2  default null
  ,p_pcd_attribute25                in  varchar2  default null
  ,p_pcd_attribute26                in  varchar2  default null
  ,p_pcd_attribute27                in  varchar2  default null
  ,p_pcd_attribute28                in  varchar2  default null
  ,p_pcd_attribute29                in  varchar2  default null
  ,p_pcd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_PER_CM_PRVDD >---------------------------|
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
--   p_per_cm_prvdd_id              Yes  number    PK of record
--   p_rqstd_flag                   Yes  varchar2
--   p_per_cm_prvdd_stat_cd         No   varchar2
--   p_cm_dlvry_med_cd              No   varchar2
--   p_cm_dlvry_mthd_cd             No   varchar2
--   p_sent_dt                      No   date
--   p_instnc_num                   No   number
--   p_to_be_sent_dt                No   date
--   p_dlvry_instn_txt              No   varchar2
--   p_inspn_rqd_flag               Yes  varchar2
--   p_resnd_rsn_cd                 No   varchar2
--   p_resnd_cmnt_txt               No   varchar2
--   p_per_cm_id                    Yes  number
--   p_address_id                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcd_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcd_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcd_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcd_attribute30              No   varchar2  Descriptive Flexfield
--   p_request_id                   No   number
--   p_program_application_id       No   number
--   p_program_id                   No   number
--   p_program_update_date          No   date
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
procedure update_PER_CM_PRVDD
  (p_validate                       in boolean    default false
  ,p_per_cm_prvdd_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default hr_api.g_varchar2
  ,p_cm_dlvry_med_cd                in  varchar2  default hr_api.g_varchar2
  ,p_cm_dlvry_mthd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_sent_dt                        in  date      default hr_api.g_date
  ,p_instnc_num                     in  number    default hr_api.g_number
  ,p_to_be_sent_dt                  in  date      default hr_api.g_date
  ,p_dlvry_instn_txt                in  varchar2  default hr_api.g_varchar2
  ,p_inspn_rqd_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_resnd_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_resnd_cmnt_txt                 in  varchar2  default hr_api.g_varchar2
  ,p_per_cm_id                      in  number    default hr_api.g_number
  ,p_address_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PER_CM_PRVDD >---------------------------|
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
--   p_per_cm_prvdd_id              Yes  number    PK of record
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
procedure delete_PER_CM_PRVDD
  (p_validate                       in boolean        default false
  ,p_per_cm_prvdd_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
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
--   p_per_cm_prvdd_id                 Yes  number   PK of record
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
   (p_per_cm_prvdd_id             in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date);
--
end ben_PER_CM_PRVDD_api;

 

/
