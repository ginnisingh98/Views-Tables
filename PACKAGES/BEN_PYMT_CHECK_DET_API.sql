--------------------------------------------------------
--  DDL for Package BEN_PYMT_CHECK_DET_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYMT_CHECK_DET_API" AUTHID CURRENT_USER as
/* $Header: bepdtapi.pkh 120.0 2005/05/28 10:28:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pymt_check_det >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   Commit or Rollback.
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_check_num                    No   varchar2
--   p_pymt_dt                      No   date
--   p_pymt_amt                     No   number
--   p_pdt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pdt_attribute1               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute2               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute3               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute4               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute5               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute6               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute7               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute8               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute9               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute10              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute11              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute12              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute13              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute14              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute15              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute16              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute17              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute18              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute19              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute20              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute21              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute22              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute23              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute24              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute25              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute26              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute27              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute28              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute29              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pymt_check_det_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pymt_check_det
(
   p_validate                       in boolean    default false
  ,p_pymt_check_det_id              out nocopy number
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_check_num                      in  varchar2  default null
  ,p_pymt_dt                        in  date      default null
  ,p_pymt_amt                       in  number    default null
  ,p_pdt_attribute_category         in  varchar2  default null
  ,p_pdt_attribute1                 in  varchar2  default null
  ,p_pdt_attribute2                 in  varchar2  default null
  ,p_pdt_attribute3                 in  varchar2  default null
  ,p_pdt_attribute4                 in  varchar2  default null
  ,p_pdt_attribute5                 in  varchar2  default null
  ,p_pdt_attribute6                 in  varchar2  default null
  ,p_pdt_attribute7                 in  varchar2  default null
  ,p_pdt_attribute8                 in  varchar2  default null
  ,p_pdt_attribute9                 in  varchar2  default null
  ,p_pdt_attribute10                in  varchar2  default null
  ,p_pdt_attribute11                in  varchar2  default null
  ,p_pdt_attribute12                in  varchar2  default null
  ,p_pdt_attribute13                in  varchar2  default null
  ,p_pdt_attribute14                in  varchar2  default null
  ,p_pdt_attribute15                in  varchar2  default null
  ,p_pdt_attribute16                in  varchar2  default null
  ,p_pdt_attribute17                in  varchar2  default null
  ,p_pdt_attribute18                in  varchar2  default null
  ,p_pdt_attribute19                in  varchar2  default null
  ,p_pdt_attribute20                in  varchar2  default null
  ,p_pdt_attribute21                in  varchar2  default null
  ,p_pdt_attribute22                in  varchar2  default null
  ,p_pdt_attribute23                in  varchar2  default null
  ,p_pdt_attribute24                in  varchar2  default null
  ,p_pdt_attribute25                in  varchar2  default null
  ,p_pdt_attribute26                in  varchar2  default null
  ,p_pdt_attribute27                in  varchar2  default null
  ,p_pdt_attribute28                in  varchar2  default null
  ,p_pdt_attribute29                in  varchar2  default null
  ,p_pdt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_pymt_check_det >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   Commit or Rollback.
--   p_pymt_check_det_id            Yes  number    PK of record
--   p_person_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_check_num                    No   varchar2
--   p_pymt_dt                      No   date
--   p_pymt_amt                     No   number
--   p_pdt_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pdt_attribute1               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute2               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute3               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute4               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute5               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute6               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute7               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute8               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute9               No   varchar2  Descriptive Flexfield
--   p_pdt_attribute10              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute11              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute12              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute13              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute14              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute15              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute16              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute17              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute18              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute19              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute20              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute21              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute22              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute23              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute24              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute25              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute26              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute27              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute28              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute29              No   varchar2  Descriptive Flexfield
--   p_pdt_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
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
procedure update_pymt_check_det
  (
   p_validate                       in boolean    default false
  ,p_pymt_check_det_id              in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_check_num                      in  varchar2  default hr_api.g_varchar2
  ,p_pymt_dt                        in  date      default hr_api.g_date
  ,p_pymt_amt                       in  number    default hr_api.g_number
  ,p_pdt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pymt_check_det >--------------------------|
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
--   p_pymt_check_det_id            Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
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
procedure delete_pymt_check_det
  (
   p_validate                       in boolean        default false
  ,p_pymt_check_det_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
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
--   p_pymt_check_det_id            Yes  number   PK of record
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
    p_pymt_check_det_id            in number
   ,p_object_version_number        in number
  );
--
end ben_pymt_check_det_api;

 

/
