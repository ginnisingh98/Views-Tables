--------------------------------------------------------
--  DDL for Package BEN_DESIGN_RQMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DESIGN_RQMT_API" AUTHID CURRENT_USER as
/* $Header: beddrapi.pkh 120.0 2005/05/28 01:35:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_design_rqmt >------------------------|
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
--   p_mn_dpnts_rqd_num             No   number
--   p_mx_dpnts_alwd_num            No   number
--   p_no_mn_num_dfnd_flag          Yes  varchar2
--   p_no_mx_num_dfnd_flag          Yes  varchar2
--   p_cvr_all_elig_flag            Yes  varchar2
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_opt_id                       No   number
--   p_grp_rlshp_cd                 No   varchar2
--   p_dsgn_typ_cd                  No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ddr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ddr_attribute1               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute2               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute3               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute4               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute5               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute6               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute7               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute8               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute9               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute10              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute11              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute12              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute13              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute14              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute15              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute16              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute17              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute18              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute19              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute20              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute21              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute22              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute23              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute24              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute25              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute26              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute27              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute28              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute29              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_dsgn_rqmt_id                 Yes  number    PK of record
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
procedure create_design_rqmt
(
   p_validate                       in boolean    default false
  ,p_dsgn_rqmt_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mn_dpnts_rqd_num               in  number    default null
  ,p_mx_dpnts_alwd_num              in  number    default null
  ,p_no_mn_num_dfnd_flag            in  varchar2  default null
  ,p_no_mx_num_dfnd_flag            in  varchar2  default null
  ,p_cvr_all_elig_flag              in  varchar2  default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_grp_rlshp_cd                   in  varchar2  default null
  ,p_dsgn_typ_cd                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_ddr_attribute_category         in  varchar2  default null
  ,p_ddr_attribute1                 in  varchar2  default null
  ,p_ddr_attribute2                 in  varchar2  default null
  ,p_ddr_attribute3                 in  varchar2  default null
  ,p_ddr_attribute4                 in  varchar2  default null
  ,p_ddr_attribute5                 in  varchar2  default null
  ,p_ddr_attribute6                 in  varchar2  default null
  ,p_ddr_attribute7                 in  varchar2  default null
  ,p_ddr_attribute8                 in  varchar2  default null
  ,p_ddr_attribute9                 in  varchar2  default null
  ,p_ddr_attribute10                in  varchar2  default null
  ,p_ddr_attribute11                in  varchar2  default null
  ,p_ddr_attribute12                in  varchar2  default null
  ,p_ddr_attribute13                in  varchar2  default null
  ,p_ddr_attribute14                in  varchar2  default null
  ,p_ddr_attribute15                in  varchar2  default null
  ,p_ddr_attribute16                in  varchar2  default null
  ,p_ddr_attribute17                in  varchar2  default null
  ,p_ddr_attribute18                in  varchar2  default null
  ,p_ddr_attribute19                in  varchar2  default null
  ,p_ddr_attribute20                in  varchar2  default null
  ,p_ddr_attribute21                in  varchar2  default null
  ,p_ddr_attribute22                in  varchar2  default null
  ,p_ddr_attribute23                in  varchar2  default null
  ,p_ddr_attribute24                in  varchar2  default null
  ,p_ddr_attribute25                in  varchar2  default null
  ,p_ddr_attribute26                in  varchar2  default null
  ,p_ddr_attribute27                in  varchar2  default null
  ,p_ddr_attribute28                in  varchar2  default null
  ,p_ddr_attribute29                in  varchar2  default null
  ,p_ddr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_design_rqmt >------------------------|
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
--   p_dsgn_rqmt_id                 Yes  number    PK of record
--   p_mn_dpnts_rqd_num             No   number
--   p_mx_dpnts_alwd_num            No   number
--   p_no_mn_num_dfnd_flag          Yes  varchar2
--   p_no_mx_num_dfnd_flag          Yes  varchar2
--   p_cvr_all_elig_flag            Yes  varchar2
--   p_oipl_id                      No   number
--   p_pl_id                        No   number
--   p_opt_id                       No   number
--   p_grp_rlshp_cd                 No   varchar2
--   p_dsgn_typ_cd                  No   varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_ddr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_ddr_attribute1               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute2               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute3               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute4               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute5               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute6               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute7               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute8               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute9               No   varchar2  Descriptive Flexfield
--   p_ddr_attribute10              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute11              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute12              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute13              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute14              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute15              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute16              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute17              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute18              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute19              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute20              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute21              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute22              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute23              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute24              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute25              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute26              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute27              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute28              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute29              No   varchar2  Descriptive Flexfield
--   p_ddr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_design_rqmt
  (
   p_validate                       in boolean    default false
  ,p_dsgn_rqmt_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_mn_dpnts_rqd_num               in  number    default hr_api.g_number
  ,p_mx_dpnts_alwd_num              in  number    default hr_api.g_number
  ,p_no_mn_num_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_num_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_cvr_all_elig_flag              in  varchar2  default hr_api.g_varchar2
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_grp_rlshp_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ddr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ddr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_design_rqmt >------------------------|
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
--   p_dsgn_rqmt_id                 Yes  number    PK of record
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
procedure delete_design_rqmt
  (
   p_validate                       in boolean        default false
  ,p_dsgn_rqmt_id                   in  number
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
--   p_dsgn_rqmt_id                 Yes  number   PK of record
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
    p_dsgn_rqmt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_design_rqmt_api;

 

/
