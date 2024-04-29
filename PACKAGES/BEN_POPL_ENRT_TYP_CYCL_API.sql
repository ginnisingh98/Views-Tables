--------------------------------------------------------
--  DDL for Package BEN_POPL_ENRT_TYP_CYCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_ENRT_TYP_CYCL_API" AUTHID CURRENT_USER as
/* $Header: bepetapi.pkh 120.0 2005/05/28 10:40:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Popl_Enrt_Typ_Cycl >------------------------|
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
--   p_enrt_typ_cycl_cd             Yes  varchar2
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_pet_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pet_attribute1               No   varchar2  Descriptive Flexfield
--   p_pet_attribute2               No   varchar2  Descriptive Flexfield
--   p_pet_attribute3               No   varchar2  Descriptive Flexfield
--   p_pet_attribute4               No   varchar2  Descriptive Flexfield
--   p_pet_attribute5               No   varchar2  Descriptive Flexfield
--   p_pet_attribute6               No   varchar2  Descriptive Flexfield
--   p_pet_attribute7               No   varchar2  Descriptive Flexfield
--   p_pet_attribute8               No   varchar2  Descriptive Flexfield
--   p_pet_attribute9               No   varchar2  Descriptive Flexfield
--   p_pet_attribute10              No   varchar2  Descriptive Flexfield
--   p_pet_attribute11              No   varchar2  Descriptive Flexfield
--   p_pet_attribute12              No   varchar2  Descriptive Flexfield
--   p_pet_attribute13              No   varchar2  Descriptive Flexfield
--   p_pet_attribute14              No   varchar2  Descriptive Flexfield
--   p_pet_attribute15              No   varchar2  Descriptive Flexfield
--   p_pet_attribute16              No   varchar2  Descriptive Flexfield
--   p_pet_attribute17              No   varchar2  Descriptive Flexfield
--   p_pet_attribute18              No   varchar2  Descriptive Flexfield
--   p_pet_attribute19              No   varchar2  Descriptive Flexfield
--   p_pet_attribute20              No   varchar2  Descriptive Flexfield
--   p_pet_attribute21              No   varchar2  Descriptive Flexfield
--   p_pet_attribute22              No   varchar2  Descriptive Flexfield
--   p_pet_attribute23              No   varchar2  Descriptive Flexfield
--   p_pet_attribute24              No   varchar2  Descriptive Flexfield
--   p_pet_attribute25              No   varchar2  Descriptive Flexfield
--   p_pet_attribute26              No   varchar2  Descriptive Flexfield
--   p_pet_attribute27              No   varchar2  Descriptive Flexfield
--   p_pet_attribute28              No   varchar2  Descriptive Flexfield
--   p_pet_attribute29              No   varchar2  Descriptive Flexfield
--   p_pet_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_popl_enrt_typ_cycl_id        Yes  number    PK of record
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
procedure create_Popl_Enrt_Typ_Cycl
(
   p_validate                       in boolean    default false
  ,p_popl_enrt_typ_cycl_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pet_attribute_category         in  varchar2  default null
  ,p_pet_attribute1                 in  varchar2  default null
  ,p_pet_attribute2                 in  varchar2  default null
  ,p_pet_attribute3                 in  varchar2  default null
  ,p_pet_attribute4                 in  varchar2  default null
  ,p_pet_attribute5                 in  varchar2  default null
  ,p_pet_attribute6                 in  varchar2  default null
  ,p_pet_attribute7                 in  varchar2  default null
  ,p_pet_attribute8                 in  varchar2  default null
  ,p_pet_attribute9                 in  varchar2  default null
  ,p_pet_attribute10                in  varchar2  default null
  ,p_pet_attribute11                in  varchar2  default null
  ,p_pet_attribute12                in  varchar2  default null
  ,p_pet_attribute13                in  varchar2  default null
  ,p_pet_attribute14                in  varchar2  default null
  ,p_pet_attribute15                in  varchar2  default null
  ,p_pet_attribute16                in  varchar2  default null
  ,p_pet_attribute17                in  varchar2  default null
  ,p_pet_attribute18                in  varchar2  default null
  ,p_pet_attribute19                in  varchar2  default null
  ,p_pet_attribute20                in  varchar2  default null
  ,p_pet_attribute21                in  varchar2  default null
  ,p_pet_attribute22                in  varchar2  default null
  ,p_pet_attribute23                in  varchar2  default null
  ,p_pet_attribute24                in  varchar2  default null
  ,p_pet_attribute25                in  varchar2  default null
  ,p_pet_attribute26                in  varchar2  default null
  ,p_pet_attribute27                in  varchar2  default null
  ,p_pet_attribute28                in  varchar2  default null
  ,p_pet_attribute29                in  varchar2  default null
  ,p_pet_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Popl_Enrt_Typ_Cycl >------------------------|
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
--   p_popl_enrt_typ_cycl_id        Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_enrt_typ_cycl_cd             Yes  varchar2
--   p_pl_id                        No   number
--   p_pgm_id                       No   number
--   p_pet_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pet_attribute1               No   varchar2  Descriptive Flexfield
--   p_pet_attribute2               No   varchar2  Descriptive Flexfield
--   p_pet_attribute3               No   varchar2  Descriptive Flexfield
--   p_pet_attribute4               No   varchar2  Descriptive Flexfield
--   p_pet_attribute5               No   varchar2  Descriptive Flexfield
--   p_pet_attribute6               No   varchar2  Descriptive Flexfield
--   p_pet_attribute7               No   varchar2  Descriptive Flexfield
--   p_pet_attribute8               No   varchar2  Descriptive Flexfield
--   p_pet_attribute9               No   varchar2  Descriptive Flexfield
--   p_pet_attribute10              No   varchar2  Descriptive Flexfield
--   p_pet_attribute11              No   varchar2  Descriptive Flexfield
--   p_pet_attribute12              No   varchar2  Descriptive Flexfield
--   p_pet_attribute13              No   varchar2  Descriptive Flexfield
--   p_pet_attribute14              No   varchar2  Descriptive Flexfield
--   p_pet_attribute15              No   varchar2  Descriptive Flexfield
--   p_pet_attribute16              No   varchar2  Descriptive Flexfield
--   p_pet_attribute17              No   varchar2  Descriptive Flexfield
--   p_pet_attribute18              No   varchar2  Descriptive Flexfield
--   p_pet_attribute19              No   varchar2  Descriptive Flexfield
--   p_pet_attribute20              No   varchar2  Descriptive Flexfield
--   p_pet_attribute21              No   varchar2  Descriptive Flexfield
--   p_pet_attribute22              No   varchar2  Descriptive Flexfield
--   p_pet_attribute23              No   varchar2  Descriptive Flexfield
--   p_pet_attribute24              No   varchar2  Descriptive Flexfield
--   p_pet_attribute25              No   varchar2  Descriptive Flexfield
--   p_pet_attribute26              No   varchar2  Descriptive Flexfield
--   p_pet_attribute27              No   varchar2  Descriptive Flexfield
--   p_pet_attribute28              No   varchar2  Descriptive Flexfield
--   p_pet_attribute29              No   varchar2  Descriptive Flexfield
--   p_pet_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Popl_Enrt_Typ_Cycl
  (
   p_validate                       in boolean    default false
  ,p_popl_enrt_typ_cycl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pet_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Popl_Enrt_Typ_Cycl >------------------------|
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
--   p_popl_enrt_typ_cycl_id        Yes  number    PK of record
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
procedure delete_Popl_Enrt_Typ_Cycl
  (
   p_validate                       in boolean        default false
  ,p_popl_enrt_typ_cycl_id          in  number
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
--   p_popl_enrt_typ_cycl_id                 Yes  number   PK of record
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
    p_popl_enrt_typ_cycl_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Popl_Enrt_Typ_Cycl_api;

 

/
