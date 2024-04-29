--------------------------------------------------------
--  DDL for Package BEN_PLAN_GOODS_SERV_CERT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_GOODS_SERV_CERT_API" AUTHID CURRENT_USER as
/* $Header: bepctapi.pkh 120.0 2005/05/28 10:17:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_plan_goods_serv_cert >------------------------|
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
--   p_pl_gd_or_svc_id              No   number
--   p_pfd_flag                     Yes  varchar2
--   p_lack_ctfn_deny_rmbmt_flag    Yes  varchar2
--   p_rmbmt_ctfn_typ_cd            Yes  varchar2
--   p_lack_ctfn_deny_rmbmt_rl      No   number
--   p_pct_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pct_attribute1               No   varchar2  Descriptive Flexfield
--   p_pct_attribute2               No   varchar2  Descriptive Flexfield
--   p_pct_attribute3               No   varchar2  Descriptive Flexfield
--   p_pct_attribute4               No   varchar2  Descriptive Flexfield
--   p_pct_attribute5               No   varchar2  Descriptive Flexfield
--   p_pct_attribute6               No   varchar2  Descriptive Flexfield
--   p_pct_attribute7               No   varchar2  Descriptive Flexfield
--   p_pct_attribute8               No   varchar2  Descriptive Flexfield
--   p_pct_attribute9               No   varchar2  Descriptive Flexfield
--   p_pct_attribute10              No   varchar2  Descriptive Flexfield
--   p_pct_attribute11              No   varchar2  Descriptive Flexfield
--   p_pct_attribute12              No   varchar2  Descriptive Flexfield
--   p_pct_attribute13              No   varchar2  Descriptive Flexfield
--   p_pct_attribute14              No   varchar2  Descriptive Flexfield
--   p_pct_attribute15              No   varchar2  Descriptive Flexfield
--   p_pct_attribute16              No   varchar2  Descriptive Flexfield
--   p_pct_attribute17              No   varchar2  Descriptive Flexfield
--   p_pct_attribute18              No   varchar2  Descriptive Flexfield
--   p_pct_attribute19              No   varchar2  Descriptive Flexfield
--   p_pct_attribute20              No   varchar2  Descriptive Flexfield
--   p_pct_attribute21              No   varchar2  Descriptive Flexfield
--   p_pct_attribute22              No   varchar2  Descriptive Flexfield
--   p_pct_attribute23              No   varchar2  Descriptive Flexfield
--   p_pct_attribute24              No   varchar2  Descriptive Flexfield
--   p_pct_attribute25              No   varchar2  Descriptive Flexfield
--   p_pct_attribute26              No   varchar2  Descriptive Flexfield
--   p_pct_attribute27              No   varchar2  Descriptive Flexfield
--   p_pct_attribute28              No   varchar2  Descriptive Flexfield
--   p_pct_attribute29              No   varchar2  Descriptive Flexfield
--   p_pct_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_gd_r_svc_ctfn_id          Yes  number    PK of record
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
procedure create_plan_goods_serv_cert
(
   p_validate                       in boolean    default false
  ,p_pl_gd_r_svc_ctfn_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_gd_or_svc_id                in  number    default null
  ,p_pfd_flag                       in  varchar2  default null
  ,p_lack_ctfn_deny_rmbmt_flag      in  varchar2  default null
  ,p_rmbmt_ctfn_typ_cd              in  varchar2  default null
  ,p_lack_ctfn_deny_rmbmt_rl        in  number    default null
  ,p_pct_attribute_category         in  varchar2  default null
  ,p_pct_attribute1                 in  varchar2  default null
  ,p_pct_attribute2                 in  varchar2  default null
  ,p_pct_attribute3                 in  varchar2  default null
  ,p_pct_attribute4                 in  varchar2  default null
  ,p_pct_attribute5                 in  varchar2  default null
  ,p_pct_attribute6                 in  varchar2  default null
  ,p_pct_attribute7                 in  varchar2  default null
  ,p_pct_attribute8                 in  varchar2  default null
  ,p_pct_attribute9                 in  varchar2  default null
  ,p_pct_attribute10                in  varchar2  default null
  ,p_pct_attribute11                in  varchar2  default null
  ,p_pct_attribute12                in  varchar2  default null
  ,p_pct_attribute13                in  varchar2  default null
  ,p_pct_attribute14                in  varchar2  default null
  ,p_pct_attribute15                in  varchar2  default null
  ,p_pct_attribute16                in  varchar2  default null
  ,p_pct_attribute17                in  varchar2  default null
  ,p_pct_attribute18                in  varchar2  default null
  ,p_pct_attribute19                in  varchar2  default null
  ,p_pct_attribute20                in  varchar2  default null
  ,p_pct_attribute21                in  varchar2  default null
  ,p_pct_attribute22                in  varchar2  default null
  ,p_pct_attribute23                in  varchar2  default null
  ,p_pct_attribute24                in  varchar2  default null
  ,p_pct_attribute25                in  varchar2  default null
  ,p_pct_attribute26                in  varchar2  default null
  ,p_pct_attribute27                in  varchar2  default null
  ,p_pct_attribute28                in  varchar2  default null
  ,p_pct_attribute29                in  varchar2  default null
  ,p_pct_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_ctfn_rqd_when_rl               in number
  ,p_rqd_flag                       in varchar2
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_plan_goods_serv_cert >------------------------|
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
--   p_pl_gd_r_svc_ctfn_id          Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_gd_or_svc_id              No   number
--   p_pfd_flag                     Yes  varchar2
--   p_lack_ctfn_deny_rmbmt_flag    Yes  varchar2
--   p_rmbmt_ctfn_typ_cd            Yes  varchar2
--   p_lack_ctfn_deny_rmbmt_rl      No   number
--   p_pct_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pct_attribute1               No   varchar2  Descriptive Flexfield
--   p_pct_attribute2               No   varchar2  Descriptive Flexfield
--   p_pct_attribute3               No   varchar2  Descriptive Flexfield
--   p_pct_attribute4               No   varchar2  Descriptive Flexfield
--   p_pct_attribute5               No   varchar2  Descriptive Flexfield
--   p_pct_attribute6               No   varchar2  Descriptive Flexfield
--   p_pct_attribute7               No   varchar2  Descriptive Flexfield
--   p_pct_attribute8               No   varchar2  Descriptive Flexfield
--   p_pct_attribute9               No   varchar2  Descriptive Flexfield
--   p_pct_attribute10              No   varchar2  Descriptive Flexfield
--   p_pct_attribute11              No   varchar2  Descriptive Flexfield
--   p_pct_attribute12              No   varchar2  Descriptive Flexfield
--   p_pct_attribute13              No   varchar2  Descriptive Flexfield
--   p_pct_attribute14              No   varchar2  Descriptive Flexfield
--   p_pct_attribute15              No   varchar2  Descriptive Flexfield
--   p_pct_attribute16              No   varchar2  Descriptive Flexfield
--   p_pct_attribute17              No   varchar2  Descriptive Flexfield
--   p_pct_attribute18              No   varchar2  Descriptive Flexfield
--   p_pct_attribute19              No   varchar2  Descriptive Flexfield
--   p_pct_attribute20              No   varchar2  Descriptive Flexfield
--   p_pct_attribute21              No   varchar2  Descriptive Flexfield
--   p_pct_attribute22              No   varchar2  Descriptive Flexfield
--   p_pct_attribute23              No   varchar2  Descriptive Flexfield
--   p_pct_attribute24              No   varchar2  Descriptive Flexfield
--   p_pct_attribute25              No   varchar2  Descriptive Flexfield
--   p_pct_attribute26              No   varchar2  Descriptive Flexfield
--   p_pct_attribute27              No   varchar2  Descriptive Flexfield
--   p_pct_attribute28              No   varchar2  Descriptive Flexfield
--   p_pct_attribute29              No   varchar2  Descriptive Flexfield
--   p_pct_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_plan_goods_serv_cert
  (
   p_validate                       in boolean    default false
  ,p_pl_gd_r_svc_ctfn_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_gd_or_svc_id                in  number    default hr_api.g_number
  ,p_pfd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_deny_rmbmt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_rmbmt_ctfn_typ_cd              in  varchar2  default hr_api.g_varchar2
  ,p_lack_ctfn_deny_rmbmt_rl        in  number    default hr_api.g_number
  ,p_pct_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pct_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_ctfn_rqd_when_rl               in  number    default hr_api.g_number
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2

  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_plan_goods_serv_cert >------------------------|
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
--   p_pl_gd_r_svc_ctfn_id          Yes  number    PK of record
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
procedure delete_plan_goods_serv_cert
  (
   p_validate                       in boolean        default false
  ,p_pl_gd_r_svc_ctfn_id            in  number
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
--   p_pl_gd_r_svc_ctfn_id                 Yes  number   PK of record
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
    p_pl_gd_r_svc_ctfn_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_plan_goods_serv_cert_api;

 

/
