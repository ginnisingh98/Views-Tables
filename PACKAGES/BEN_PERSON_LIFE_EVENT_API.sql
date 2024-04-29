--------------------------------------------------------
--  DDL for Package BEN_PERSON_LIFE_EVENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_LIFE_EVENT_API" AUTHID CURRENT_USER as
/* $Header: bepilapi.pkh 120.0 2005/05/28 10:49:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_Person_Life_Event >------------------------|
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
--   p_per_in_ler_stat_cd           No   varchar2
--   p_prev_stat_cd                 No   varchar2
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_procd_dt                     No   date
--   p_strtd_dt                     No   date
--   p_voidd_dt                     No   date
--   p_bckt_dt                      No   date
--   p_clsd_dt                      No   date
--   p_ntfn_dt                      No   date
--   p_ptnl_ler_for_per_id          Yes  number
--   p_bckt_per_in_ler_id           No   number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pil_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pil_attribute1               No   varchar2  Descriptive Flexfield
--   p_pil_attribute2               No   varchar2  Descriptive Flexfield
--   p_pil_attribute3               No   varchar2  Descriptive Flexfield
--   p_pil_attribute4               No   varchar2  Descriptive Flexfield
--   p_pil_attribute5               No   varchar2  Descriptive Flexfield
--   p_pil_attribute6               No   varchar2  Descriptive Flexfield
--   p_pil_attribute7               No   varchar2  Descriptive Flexfield
--   p_pil_attribute8               No   varchar2  Descriptive Flexfield
--   p_pil_attribute9               No   varchar2  Descriptive Flexfield
--   p_pil_attribute10              No   varchar2  Descriptive Flexfield
--   p_pil_attribute11              No   varchar2  Descriptive Flexfield
--   p_pil_attribute12              No   varchar2  Descriptive Flexfield
--   p_pil_attribute13              No   varchar2  Descriptive Flexfield
--   p_pil_attribute14              No   varchar2  Descriptive Flexfield
--   p_pil_attribute15              No   varchar2  Descriptive Flexfield
--   p_pil_attribute16              No   varchar2  Descriptive Flexfield
--   p_pil_attribute17              No   varchar2  Descriptive Flexfield
--   p_pil_attribute18              No   varchar2  Descriptive Flexfield
--   p_pil_attribute19              No   varchar2  Descriptive Flexfield
--   p_pil_attribute20              No   varchar2  Descriptive Flexfield
--   p_pil_attribute21              No   varchar2  Descriptive Flexfield
--   p_pil_attribute22              No   varchar2  Descriptive Flexfield
--   p_pil_attribute23              No   varchar2  Descriptive Flexfield
--   p_pil_attribute24              No   varchar2  Descriptive Flexfield
--   p_pil_attribute25              No   varchar2  Descriptive Flexfield
--   p_pil_attribute26              No   varchar2  Descriptive Flexfield
--   p_pil_attribute27              No   varchar2  Descriptive Flexfield
--   p_pil_attribute28              No   varchar2  Descriptive Flexfield
--   p_pil_attribute29              No   varchar2  Descriptive Flexfield
--   p_pil_attribute30              No   varchar2  Descriptive Flexfield
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
--   p_per_in_ler_id                Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Person_Life_Event
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  out NOCOPY number
  ,p_per_in_ler_stat_cd             in  varchar2  default null
  ,p_prvs_stat_cd                   in  varchar2  default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default null
  ,p_clsd_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_ptnl_ler_for_per_id            in  number    default null
  ,p_bckt_per_in_ler_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ASSIGNMENT_ID                  in  number    default null
  ,p_WS_MGR_ID                      in  number    default null
  ,p_GROUP_PL_ID                    in  number    default null
  ,p_MGR_OVRID_PERSON_ID            in  number    default null
  ,p_MGR_OVRID_DT                   in  date      default null
  ,p_pil_attribute_category         in  varchar2  default null
  ,p_pil_attribute1                 in  varchar2  default null
  ,p_pil_attribute2                 in  varchar2  default null
  ,p_pil_attribute3                 in  varchar2  default null
  ,p_pil_attribute4                 in  varchar2  default null
  ,p_pil_attribute5                 in  varchar2  default null
  ,p_pil_attribute6                 in  varchar2  default null
  ,p_pil_attribute7                 in  varchar2  default null
  ,p_pil_attribute8                 in  varchar2  default null
  ,p_pil_attribute9                 in  varchar2  default null
  ,p_pil_attribute10                in  varchar2  default null
  ,p_pil_attribute11                in  varchar2  default null
  ,p_pil_attribute12                in  varchar2  default null
  ,p_pil_attribute13                in  varchar2  default null
  ,p_pil_attribute14                in  varchar2  default null
  ,p_pil_attribute15                in  varchar2  default null
  ,p_pil_attribute16                in  varchar2  default null
  ,p_pil_attribute17                in  varchar2  default null
  ,p_pil_attribute18                in  varchar2  default null
  ,p_pil_attribute19                in  varchar2  default null
  ,p_pil_attribute20                in  varchar2  default null
  ,p_pil_attribute21                in  varchar2  default null
  ,p_pil_attribute22                in  varchar2  default null
  ,p_pil_attribute23                in  varchar2  default null
  ,p_pil_attribute24                in  varchar2  default null
  ,p_pil_attribute25                in  varchar2  default null
  ,p_pil_attribute26                in  varchar2  default null
  ,p_pil_attribute27                in  varchar2  default null
  ,p_pil_attribute28                in  varchar2  default null
  ,p_pil_attribute29                in  varchar2  default null
  ,p_pil_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |----------------------< create_Person_Life_Event_perf >-------------------|
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
--   p_per_in_ler_stat_cd           No   varchar2
--   p_prvs_stat_cd                 No   varchar2
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_procd_dt                     No   date
--   p_strtd_dt                     No   date
--   p_voidd_dt                     No   date
--   p_bckt_dt                      No   date
--   p_clsd_dt                      No   date
--   p_ntfn_dt                      No   date
--   p_ptnl_ler_for_per_id          Yes  number
--   p_bckt_per_in_ler_id           No   number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pil_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pil_attribute1               No   varchar2  Descriptive Flexfield
--   p_pil_attribute2               No   varchar2  Descriptive Flexfield
--   p_pil_attribute3               No   varchar2  Descriptive Flexfield
--   p_pil_attribute4               No   varchar2  Descriptive Flexfield
--   p_pil_attribute5               No   varchar2  Descriptive Flexfield
--   p_pil_attribute6               No   varchar2  Descriptive Flexfield
--   p_pil_attribute7               No   varchar2  Descriptive Flexfield
--   p_pil_attribute8               No   varchar2  Descriptive Flexfield
--   p_pil_attribute9               No   varchar2  Descriptive Flexfield
--   p_pil_attribute10              No   varchar2  Descriptive Flexfield
--   p_pil_attribute11              No   varchar2  Descriptive Flexfield
--   p_pil_attribute12              No   varchar2  Descriptive Flexfield
--   p_pil_attribute13              No   varchar2  Descriptive Flexfield
--   p_pil_attribute14              No   varchar2  Descriptive Flexfield
--   p_pil_attribute15              No   varchar2  Descriptive Flexfield
--   p_pil_attribute16              No   varchar2  Descriptive Flexfield
--   p_pil_attribute17              No   varchar2  Descriptive Flexfield
--   p_pil_attribute18              No   varchar2  Descriptive Flexfield
--   p_pil_attribute19              No   varchar2  Descriptive Flexfield
--   p_pil_attribute20              No   varchar2  Descriptive Flexfield
--   p_pil_attribute21              No   varchar2  Descriptive Flexfield
--   p_pil_attribute22              No   varchar2  Descriptive Flexfield
--   p_pil_attribute23              No   varchar2  Descriptive Flexfield
--   p_pil_attribute24              No   varchar2  Descriptive Flexfield
--   p_pil_attribute25              No   varchar2  Descriptive Flexfield
--   p_pil_attribute26              No   varchar2  Descriptive Flexfield
--   p_pil_attribute27              No   varchar2  Descriptive Flexfield
--   p_pil_attribute28              No   varchar2  Descriptive Flexfield
--   p_pil_attribute29              No   varchar2  Descriptive Flexfield
--   p_pil_attribute30              No   varchar2  Descriptive Flexfield
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
--   p_per_in_ler_id                Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Person_Life_Event_perf
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  out NOCOPY number
  ,p_per_in_ler_stat_cd             in  varchar2  default null
  ,p_prvs_stat_cd                   in  varchar2  default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default null
  ,p_clsd_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_ptnl_ler_for_per_id            in  number    default null
  ,p_bckt_per_in_ler_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ASSIGNMENT_ID                  in  number    default null
  ,p_WS_MGR_ID                      in  number    default null
  ,p_GROUP_PL_ID                    in  number    default null
  ,p_MGR_OVRID_PERSON_ID            in  number    default null
  ,p_MGR_OVRID_DT                   in  date      default null
  ,p_pil_attribute_category         in  varchar2  default null
  ,p_pil_attribute1                 in  varchar2  default null
  ,p_pil_attribute2                 in  varchar2  default null
  ,p_pil_attribute3                 in  varchar2  default null
  ,p_pil_attribute4                 in  varchar2  default null
  ,p_pil_attribute5                 in  varchar2  default null
  ,p_pil_attribute6                 in  varchar2  default null
  ,p_pil_attribute7                 in  varchar2  default null
  ,p_pil_attribute8                 in  varchar2  default null
  ,p_pil_attribute9                 in  varchar2  default null
  ,p_pil_attribute10                in  varchar2  default null
  ,p_pil_attribute11                in  varchar2  default null
  ,p_pil_attribute12                in  varchar2  default null
  ,p_pil_attribute13                in  varchar2  default null
  ,p_pil_attribute14                in  varchar2  default null
  ,p_pil_attribute15                in  varchar2  default null
  ,p_pil_attribute16                in  varchar2  default null
  ,p_pil_attribute17                in  varchar2  default null
  ,p_pil_attribute18                in  varchar2  default null
  ,p_pil_attribute19                in  varchar2  default null
  ,p_pil_attribute20                in  varchar2  default null
  ,p_pil_attribute21                in  varchar2  default null
  ,p_pil_attribute22                in  varchar2  default null
  ,p_pil_attribute23                in  varchar2  default null
  ,p_pil_attribute24                in  varchar2  default null
  ,p_pil_attribute25                in  varchar2  default null
  ,p_pil_attribute26                in  varchar2  default null
  ,p_pil_attribute27                in  varchar2  default null
  ,p_pil_attribute28                in  varchar2  default null
  ,p_pil_attribute29                in  varchar2  default null
  ,p_pil_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |----------------------< update_Person_Life_Event >------------------------|
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
--   p_per_in_ler_id                Yes  number    PK of record
--   p_per_in_ler_stat_cd           No   varchar2
--   p_prvs_stat_cd                 No   varchar2
--   p_lf_evt_ocrd_dt               Yes  date
--   p_trgr_table_pk_id             No   number
--   p_procd_dt                     No   date
--   p_strtd_dt                     No   date
--   p_voidd_dt                     No   date
--   p_bckt_dt                      No   date
--   p_clsd_dt                      No   date
--   p_ntfn_dt                      No   date
--   p_ptnl_ler_for_per_id          Yes  number
--   p_bckt_per_in_ler_id           No   number
--   p_ler_id                       Yes  number
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pil_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pil_attribute1               No   varchar2  Descriptive Flexfield
--   p_pil_attribute2               No   varchar2  Descriptive Flexfield
--   p_pil_attribute3               No   varchar2  Descriptive Flexfield
--   p_pil_attribute4               No   varchar2  Descriptive Flexfield
--   p_pil_attribute5               No   varchar2  Descriptive Flexfield
--   p_pil_attribute6               No   varchar2  Descriptive Flexfield
--   p_pil_attribute7               No   varchar2  Descriptive Flexfield
--   p_pil_attribute8               No   varchar2  Descriptive Flexfield
--   p_pil_attribute9               No   varchar2  Descriptive Flexfield
--   p_pil_attribute10              No   varchar2  Descriptive Flexfield
--   p_pil_attribute11              No   varchar2  Descriptive Flexfield
--   p_pil_attribute12              No   varchar2  Descriptive Flexfield
--   p_pil_attribute13              No   varchar2  Descriptive Flexfield
--   p_pil_attribute14              No   varchar2  Descriptive Flexfield
--   p_pil_attribute15              No   varchar2  Descriptive Flexfield
--   p_pil_attribute16              No   varchar2  Descriptive Flexfield
--   p_pil_attribute17              No   varchar2  Descriptive Flexfield
--   p_pil_attribute18              No   varchar2  Descriptive Flexfield
--   p_pil_attribute19              No   varchar2  Descriptive Flexfield
--   p_pil_attribute20              No   varchar2  Descriptive Flexfield
--   p_pil_attribute21              No   varchar2  Descriptive Flexfield
--   p_pil_attribute22              No   varchar2  Descriptive Flexfield
--   p_pil_attribute23              No   varchar2  Descriptive Flexfield
--   p_pil_attribute24              No   varchar2  Descriptive Flexfield
--   p_pil_attribute25              No   varchar2  Descriptive Flexfield
--   p_pil_attribute26              No   varchar2  Descriptive Flexfield
--   p_pil_attribute27              No   varchar2  Descriptive Flexfield
--   p_pil_attribute28              No   varchar2  Descriptive Flexfield
--   p_pil_attribute29              No   varchar2  Descriptive Flexfield
--   p_pil_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Person_Life_Event
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  in  number
  ,p_per_in_ler_stat_cd             in  varchar2  default hr_api.g_varchar2
  ,p_prvs_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default hr_api.g_date
  ,p_clsd_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_ptnl_ler_for_per_id            in  number    default hr_api.g_number
  ,p_bckt_per_in_ler_id             in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ASSIGNMENT_ID                  in  number    default hr_api.g_number
  ,p_WS_MGR_ID                      in  number    default hr_api.g_number
  ,p_GROUP_PL_ID                    in  number    default hr_api.g_number
  ,p_MGR_OVRID_PERSON_ID            in  number    default hr_api.g_number
  ,p_MGR_OVRID_DT                   in  date      default hr_api.g_date
  ,p_pil_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_Person_Life_Event >------------------------|
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
--   p_per_in_ler_id                Yes  number    PK of record
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
procedure delete_Person_Life_Event
  (p_validate                       in boolean        default false
  ,p_per_in_ler_id                  in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in date);
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
--   p_per_in_ler_id                 Yes  number   PK of record
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
   (p_per_in_ler_id                in number
   ,p_object_version_number        in number);
--
end ben_Person_Life_Event_api;

 

/
