--------------------------------------------------------
--  DDL for Package BEN_PERSON_LIFE_EVENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_LIFE_EVENT_SWI" AUTHID CURRENT_USER As
/* $Header: bepilswi.pkh 120.0 2005/05/28 10:51:12 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_Person_Life_Event_api.create_Person_Life_Event
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
PROCEDURE create_Person_Life_Event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_in_ler_id                  out NOCOPY number
   ,p_per_in_ler_stat_cd             in  varchar2  default null
   ,p_prvs_stat_cd                   in  varchar2  default null
   ,p_lf_evt_ocrd_dt                 in  date      default null
   ,p_trgr_table_pk_id               in  number    default null --ABSE changes
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
  ,p_effective_date                 in  date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_Person_Life_Event_api.delete_Person_Life_Event
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
PROCEDURE delete_Person_Life_Event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_in_ler_id                  in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_Person_Life_Event_api.lck
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
  (p_per_in_ler_id                  in     number
  ,p_object_version_number          in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_Person_Life_Event_api.update_Person_Life_Event
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
PROCEDURE update_Person_Life_Event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_in_ler_id                  in  number
    ,p_per_in_ler_stat_cd             in  varchar2  default hr_api.g_varchar2
    ,p_prvs_stat_cd                   in  varchar2  default hr_api.g_varchar2
    ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
    ,p_trgr_table_pk_id               in  number    default hr_api.g_number --ABSE changes
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
  ,p_effective_date                 in  date
  ,p_return_status                   out nocopy varchar2
  );
end ben_person_life_event_swi;

 

/
