--------------------------------------------------------
--  DDL for Package BEN_PRTT_CLM_GD_R_SVC_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_CLM_GD_R_SVC_TYP_API" AUTHID CURRENT_USER as
/* $Header: bepcgapi.pkh 120.0 2005/05/28 10:10:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_CLM_GD_R_SVC_TYP >------------------------|
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
--   p_prtt_reimbmt_rqst_id         Yes  number
--   p_gd_or_svc_typ_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcg_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcg_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute30              No   varchar2  Descriptive Flexfield
--   p_pl_gd_or_svc_id             No   number
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_clm_gd_or_svc_typ_id    Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_PRTT_CLM_GD_R_SVC_TYP
(
   p_validate                       in boolean    default false
  ,p_prtt_clm_gd_or_svc_typ_id      out nocopy number
  ,p_prtt_reimbmt_rqst_id           in  number    default null
  ,p_gd_or_svc_typ_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcg_attribute_category         in  varchar2  default null
  ,p_pcg_attribute1                 in  varchar2  default null
  ,p_pcg_attribute2                 in  varchar2  default null
  ,p_pcg_attribute3                 in  varchar2  default null
  ,p_pcg_attribute4                 in  varchar2  default null
  ,p_pcg_attribute5                 in  varchar2  default null
  ,p_pcg_attribute6                 in  varchar2  default null
  ,p_pcg_attribute7                 in  varchar2  default null
  ,p_pcg_attribute8                 in  varchar2  default null
  ,p_pcg_attribute9                 in  varchar2  default null
  ,p_pcg_attribute10                in  varchar2  default null
  ,p_pcg_attribute11                in  varchar2  default null
  ,p_pcg_attribute12                in  varchar2  default null
  ,p_pcg_attribute13                in  varchar2  default null
  ,p_pcg_attribute14                in  varchar2  default null
  ,p_pcg_attribute15                in  varchar2  default null
  ,p_pcg_attribute16                in  varchar2  default null
  ,p_pcg_attribute17                in  varchar2  default null
  ,p_pcg_attribute18                in  varchar2  default null
  ,p_pcg_attribute19                in  varchar2  default null
  ,p_pcg_attribute20                in  varchar2  default null
  ,p_pcg_attribute21                in  varchar2  default null
  ,p_pcg_attribute22                in  varchar2  default null
  ,p_pcg_attribute23                in  varchar2  default null
  ,p_pcg_attribute24                in  varchar2  default null
  ,p_pcg_attribute25                in  varchar2  default null
  ,p_pcg_attribute26                in  varchar2  default null
  ,p_pcg_attribute27                in  varchar2  default null
  ,p_pcg_attribute28                in  varchar2  default null
  ,p_pcg_attribute29                in  varchar2  default null
  ,p_pcg_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_pl_gd_or_svc_id                in  number    default null
  ,p_effective_date                 in  date      default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_CLM_GD_R_SVC_TYP >------------------------|
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
--   p_prtt_clm_gd_or_svc_typ_id    Yes  number    PK of record
--   p_prtt_reimbmt_rqst_id         Yes  number
--   p_gd_or_svc_typ_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pcg_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pcg_attribute1               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute2               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute3               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute4               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute5               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute6               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute7               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute8               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute9               No   varchar2  Descriptive Flexfield
--   p_pcg_attribute10              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute11              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute12              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute13              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute14              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute15              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute16              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute17              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute18              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute19              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute20              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute21              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute22              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute23              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute24              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute25              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute26              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute27              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute28              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute29              No   varchar2  Descriptive Flexfield
--   p_pcg_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_PRTT_CLM_GD_R_SVC_TYP
  (
   p_validate                       in boolean    default false
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_gd_or_svc_typ_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcg_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_pl_gd_or_svc_id                in  number    default hr_api.g_number
  ,p_effective_date                 in  date      default null
  );

procedure check_remb_rqst_ctfn_rqs
    (p_prtt_reimbmt_rqst_id in number    default null
    ,p_pl_gd_or_svc_id      in number    default null
    ,p_effective_date       in date
    ,p_ctfn_rqd_flag        out nocopy varchar2 ) ;

Procedure check_remb_rqst_ctfn_prvdd
    (p_prtt_reimbmt_rqst_id         in number    default null
     ,p_prtt_clm_gd_or_svc_typ_id   in number    default null
     ,p_effective_date              in date
     ,p_ctfn_pending_flag           out nocopy varchar2 ) ;



--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_CLM_GD_R_SVC_TYP >------------------------|
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
--   p_prtt_clm_gd_or_svc_typ_id    Yes  number    PK of record
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
procedure delete_PRTT_CLM_GD_R_SVC_TYP
  (
   p_validate                       in boolean        default false
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date      default null
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
--   p_prtt_clm_gd_or_svc_typ_id                 Yes  number   PK of record
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
    p_prtt_clm_gd_or_svc_typ_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_PRTT_CLM_GD_R_SVC_TYP_api;

 

/
