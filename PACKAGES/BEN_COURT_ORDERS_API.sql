--------------------------------------------------------
--  DDL for Package BEN_COURT_ORDERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COURT_ORDERS_API" AUTHID CURRENT_USER as
/* $Header: becrtapi.pkh 120.0 2005/05/28 01:22:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_court_orders >------------------------|
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
--   p_crt_ordr_typ_cd              Yes  varchar2
--   p_apls_perd_endg_dt            No   date
--   p_apls_perd_strtg_dt           No   date
--   p_crt_ident                    No   varchar2
--   p_description                  No   varchar2
--   p_detd_qlfd_ordr_dt            No   date
--   p_issue_dt                     No   date
--   p_qdro_amt                     No   number
--   p_qdro_dstr_mthd_cd            No   varchar2
--   p_qdro_pct                     No   number
--   p_rcvd_dt                      No   date
--   p_uom                          No   varchar2
--   p_crt_issng                    No   varchar2
--   p_pl_id                        No   number
--   p_person_id                    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crt_attribute1               No   varchar2  Descriptive Flexfield
--   p_crt_attribute2               No   varchar2  Descriptive Flexfield
--   p_crt_attribute3               No   varchar2  Descriptive Flexfield
--   p_crt_attribute4               No   varchar2  Descriptive Flexfield
--   p_crt_attribute5               No   varchar2  Descriptive Flexfield
--   p_crt_attribute6               No   varchar2  Descriptive Flexfield
--   p_crt_attribute7               No   varchar2  Descriptive Flexfield
--   p_crt_attribute8               No   varchar2  Descriptive Flexfield
--   p_crt_attribute9               No   varchar2  Descriptive Flexfield
--   p_crt_attribute10              No   varchar2  Descriptive Flexfield
--   p_crt_attribute11              No   varchar2  Descriptive Flexfield
--   p_crt_attribute12              No   varchar2  Descriptive Flexfield
--   p_crt_attribute13              No   varchar2  Descriptive Flexfield
--   p_crt_attribute14              No   varchar2  Descriptive Flexfield
--   p_crt_attribute15              No   varchar2  Descriptive Flexfield
--   p_crt_attribute16              No   varchar2  Descriptive Flexfield
--   p_crt_attribute17              No   varchar2  Descriptive Flexfield
--   p_crt_attribute18              No   varchar2  Descriptive Flexfield
--   p_crt_attribute19              No   varchar2  Descriptive Flexfield
--   p_crt_attribute20              No   varchar2  Descriptive Flexfield
--   p_crt_attribute21              No   varchar2  Descriptive Flexfield
--   p_crt_attribute22              No   varchar2  Descriptive Flexfield
--   p_crt_attribute23              No   varchar2  Descriptive Flexfield
--   p_crt_attribute24              No   varchar2  Descriptive Flexfield
--   p_crt_attribute25              No   varchar2  Descriptive Flexfield
--   p_crt_attribute26              No   varchar2  Descriptive Flexfield
--   p_crt_attribute27              No   varchar2  Descriptive Flexfield
--   p_crt_attribute28              No   varchar2  Descriptive Flexfield
--   p_crt_attribute29              No   varchar2  Descriptive Flexfield
--   p_crt_attribute30              No   varchar2  Descriptive Flexfield
--   p_qdro_num_pymt_val            No   number
--   p_qdro_per_perd_cd             No   varchar2
--   p_pl_typ_id                    No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_crt_ordr_id                  Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_court_orders
(
   p_validate                       in boolean    default false
  ,p_crt_ordr_id                    out nocopy number
  ,p_crt_ordr_typ_cd                in  varchar2  default null
  ,p_apls_perd_endg_dt              in  date      default null
  ,p_apls_perd_strtg_dt             in  date      default null
  ,p_crt_ident                      in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_detd_qlfd_ordr_dt              in  date      default null
  ,p_issue_dt                       in  date      default null
  ,p_qdro_amt                       in  number    default null
  ,p_qdro_dstr_mthd_cd              in  varchar2  default null
  ,p_qdro_pct                       in  number    default null
  ,p_rcvd_dt                        in  date      default null
  ,p_uom                            in  varchar2  default null
  ,p_crt_issng                      in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_crt_attribute_category         in  varchar2  default null
  ,p_crt_attribute1                 in  varchar2  default null
  ,p_crt_attribute2                 in  varchar2  default null
  ,p_crt_attribute3                 in  varchar2  default null
  ,p_crt_attribute4                 in  varchar2  default null
  ,p_crt_attribute5                 in  varchar2  default null
  ,p_crt_attribute6                 in  varchar2  default null
  ,p_crt_attribute7                 in  varchar2  default null
  ,p_crt_attribute8                 in  varchar2  default null
  ,p_crt_attribute9                 in  varchar2  default null
  ,p_crt_attribute10                in  varchar2  default null
  ,p_crt_attribute11                in  varchar2  default null
  ,p_crt_attribute12                in  varchar2  default null
  ,p_crt_attribute13                in  varchar2  default null
  ,p_crt_attribute14                in  varchar2  default null
  ,p_crt_attribute15                in  varchar2  default null
  ,p_crt_attribute16                in  varchar2  default null
  ,p_crt_attribute17                in  varchar2  default null
  ,p_crt_attribute18                in  varchar2  default null
  ,p_crt_attribute19                in  varchar2  default null
  ,p_crt_attribute20                in  varchar2  default null
  ,p_crt_attribute21                in  varchar2  default null
  ,p_crt_attribute22                in  varchar2  default null
  ,p_crt_attribute23                in  varchar2  default null
  ,p_crt_attribute24                in  varchar2  default null
  ,p_crt_attribute25                in  varchar2  default null
  ,p_crt_attribute26                in  varchar2  default null
  ,p_crt_attribute27                in  varchar2  default null
  ,p_crt_attribute28                in  varchar2  default null
  ,p_crt_attribute29                in  varchar2  default null
  ,p_crt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_qdro_num_pymt_val              in  number    default null
  ,p_qdro_per_perd_cd               in  varchar2  default null
  ,p_pl_typ_id                      in  number    default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_court_orders >------------------------|
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
--   p_crt_ordr_id                  Yes  number    PK of record
--   p_crt_ordr_typ_cd              Yes  varchar2
--   p_apls_perd_endg_dt            No   date
--   p_apls_perd_strtg_dt           No   date
--   p_crt_ident                    No   varchar2
--   p_description                  No   varchar2
--   p_detd_qlfd_ordr_dt            No   date
--   p_issue_dt                     No   date
--   p_qdro_amt                     No   number
--   p_qdro_dstr_mthd_cd            No   varchar2
--   p_qdro_pct                     No   number
--   p_rcvd_dt                      No   date
--   p_uom                          No   varchar2
--   p_crt_issng                    No   varchar2
--   p_pl_id                        No   number
--   p_person_id                    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_crt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_crt_attribute1               No   varchar2  Descriptive Flexfield
--   p_crt_attribute2               No   varchar2  Descriptive Flexfield
--   p_crt_attribute3               No   varchar2  Descriptive Flexfield
--   p_crt_attribute4               No   varchar2  Descriptive Flexfield
--   p_crt_attribute5               No   varchar2  Descriptive Flexfield
--   p_crt_attribute6               No   varchar2  Descriptive Flexfield
--   p_crt_attribute7               No   varchar2  Descriptive Flexfield
--   p_crt_attribute8               No   varchar2  Descriptive Flexfield
--   p_crt_attribute9               No   varchar2  Descriptive Flexfield
--   p_crt_attribute10              No   varchar2  Descriptive Flexfield
--   p_crt_attribute11              No   varchar2  Descriptive Flexfield
--   p_crt_attribute12              No   varchar2  Descriptive Flexfield
--   p_crt_attribute13              No   varchar2  Descriptive Flexfield
--   p_crt_attribute14              No   varchar2  Descriptive Flexfield
--   p_crt_attribute15              No   varchar2  Descriptive Flexfield
--   p_crt_attribute16              No   varchar2  Descriptive Flexfield
--   p_crt_attribute17              No   varchar2  Descriptive Flexfield
--   p_crt_attribute18              No   varchar2  Descriptive Flexfield
--   p_crt_attribute19              No   varchar2  Descriptive Flexfield
--   p_crt_attribute20              No   varchar2  Descriptive Flexfield
--   p_crt_attribute21              No   varchar2  Descriptive Flexfield
--   p_crt_attribute22              No   varchar2  Descriptive Flexfield
--   p_crt_attribute23              No   varchar2  Descriptive Flexfield
--   p_crt_attribute24              No   varchar2  Descriptive Flexfield
--   p_crt_attribute25              No   varchar2  Descriptive Flexfield
--   p_crt_attribute26              No   varchar2  Descriptive Flexfield
--   p_crt_attribute27              No   varchar2  Descriptive Flexfield
--   p_crt_attribute28              No   varchar2  Descriptive Flexfield
--   p_crt_attribute29              No   varchar2  Descriptive Flexfield
--   p_crt_attribute30              No   varchar2  Descriptive Flexfield
--   p_qdro_num_pymt_val            No   number
--   p_qdro_per_perd_cd             No   varchar2
--   p_pl_typ_id                    No   number
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
procedure update_court_orders
  (
   p_validate                       in boolean    default false
  ,p_crt_ordr_id                    in  number
  ,p_crt_ordr_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_apls_perd_endg_dt              in  date      default hr_api.g_date
  ,p_apls_perd_strtg_dt             in  date      default hr_api.g_date
  ,p_crt_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_detd_qlfd_ordr_dt              in  date      default hr_api.g_date
  ,p_issue_dt                       in  date      default hr_api.g_date
  ,p_qdro_amt                       in  number    default hr_api.g_number
  ,p_qdro_dstr_mthd_cd              in  varchar2  default hr_api.g_varchar2
  ,p_qdro_pct                       in  number    default hr_api.g_number
  ,p_rcvd_dt                        in  date      default hr_api.g_date
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_crt_issng                      in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_qdro_num_pymt_val              in  number    default hr_api.g_number
  ,p_qdro_per_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_court_orders >------------------------|
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
--   p_crt_ordr_id                  Yes  number    PK of record
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
procedure delete_court_orders
  (
   p_validate                       in boolean        default false
  ,p_crt_ordr_id                    in  number
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
--   p_crt_ordr_id                 Yes  number   PK of record
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
    p_crt_ordr_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_court_orders_api;

 

/
