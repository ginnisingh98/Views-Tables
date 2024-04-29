--------------------------------------------------------
--  DDL for Package BEN_REPORTING_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REPORTING_GROUP_API" AUTHID CURRENT_USER as
/* $Header: bebnrapi.pkh 120.0 2005/05/28 00:45:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Reporting_Group >------------------------|
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
--   p_rptg_prps_cd                 No   varchar2
--   p_rpg_desc                     No   varchar2
--   p_bnr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bnr_attribute1               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute2               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute3               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute4               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute5               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute6               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute7               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute8               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute9               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute10              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute11              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute12              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute13              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute14              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute15              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute16              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute17              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute18              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute19              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute20              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute21              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute22              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute23              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute24              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute25              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute26              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute27              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute28              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute29              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_rptg_grp_id                  Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Reporting_Group
(
   p_validate                       in boolean    default false
  ,p_rptg_grp_id                    out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_rptg_prps_cd                   in  varchar2  default null
  ,p_rpg_desc                       in  varchar2  default null
  ,p_bnr_attribute_category         in  varchar2  default null
  ,p_bnr_attribute1                 in  varchar2  default null
  ,p_bnr_attribute2                 in  varchar2  default null
  ,p_bnr_attribute3                 in  varchar2  default null
  ,p_bnr_attribute4                 in  varchar2  default null
  ,p_bnr_attribute5                 in  varchar2  default null
  ,p_bnr_attribute6                 in  varchar2  default null
  ,p_bnr_attribute7                 in  varchar2  default null
  ,p_bnr_attribute8                 in  varchar2  default null
  ,p_bnr_attribute9                 in  varchar2  default null
  ,p_bnr_attribute10                in  varchar2  default null
  ,p_bnr_attribute11                in  varchar2  default null
  ,p_bnr_attribute12                in  varchar2  default null
  ,p_bnr_attribute13                in  varchar2  default null
  ,p_bnr_attribute14                in  varchar2  default null
  ,p_bnr_attribute15                in  varchar2  default null
  ,p_bnr_attribute16                in  varchar2  default null
  ,p_bnr_attribute17                in  varchar2  default null
  ,p_bnr_attribute18                in  varchar2  default null
  ,p_bnr_attribute19                in  varchar2  default null
  ,p_bnr_attribute20                in  varchar2  default null
  ,p_bnr_attribute21                in  varchar2  default null
  ,p_bnr_attribute22                in  varchar2  default null
  ,p_bnr_attribute23                in  varchar2  default null
  ,p_bnr_attribute24                in  varchar2  default null
  ,p_bnr_attribute25                in  varchar2  default null
  ,p_bnr_attribute26                in  varchar2  default null
  ,p_bnr_attribute27                in  varchar2  default null
  ,p_bnr_attribute28                in  varchar2  default null
  ,p_bnr_attribute29                in  varchar2  default null
  ,p_bnr_attribute30                in  varchar2  default null
  ,p_function_code                  in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ordr_num                       in  number    default null             --iRec
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Reporting_Group >------------------------|
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
--   p_rptg_grp_id                  Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_rptg_prps_cd                 No   varchar2
--   p_rpg_desc                     No   varchar2
--   p_bnr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bnr_attribute1               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute2               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute3               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute4               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute5               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute6               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute7               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute8               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute9               No   varchar2  Descriptive Flexfield
--   p_bnr_attribute10              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute11              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute12              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute13              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute14              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute15              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute16              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute17              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute18              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute19              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute20              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute21              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute22              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute23              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute24              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute25              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute26              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute27              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute28              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute29              No   varchar2  Descriptive Flexfield
--   p_bnr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Reporting_Group
  (
   p_validate                       in boolean    default false
  ,p_rptg_grp_id                    in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rptg_prps_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rpg_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_function_code                  in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ordr_num                       in  number    default hr_api.g_number            --iRec
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Reporting_Group >------------------------|
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
--   p_rptg_grp_id                  Yes  number    PK of record
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
procedure delete_Reporting_Group
  (
   p_validate                       in boolean        default false
  ,p_rptg_grp_id                    in  number
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
--   p_rptg_grp_id                 Yes  number   PK of record
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
    p_rptg_grp_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_Reporting_Group_api;

 

/
