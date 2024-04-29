--------------------------------------------------------
--  DDL for Package BEN_LER_BNFT_RSTRN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_BNFT_RSTRN_API" AUTHID CURRENT_USER as
/* $Header: belbrapi.pkh 120.0 2005/05/28 03:16:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_LER_BNFT_RSTRN >------------------------|
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
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_mn_cvg_amt                   No   number
--   p_mn_cvg_rl                    No   number
--   p_cvg_incr_r_decr_only_cd      No   varchar2
--   p_unsspnd_enrt_cd              No   varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   varchar2
--   p_ler_id                       Yes  number
--   p_pl_id                        Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_plip_id                      Yes  number
--   p_lbr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lbr_attribute1               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute2               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute3               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute4               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute5               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute6               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute7               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute8               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute9               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute10              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute11              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute12              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute13              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute14              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute15              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute16              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute17              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute18              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute19              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute20              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute21              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute22              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute23              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute24              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute25              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute26              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute27              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute28              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute29              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ler_bnft_rstrn_id            Yes  number    PK of record
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
procedure create_LER_BNFT_RSTRN
(
   p_validate                       in boolean    default false
  ,p_ler_bnft_rstrn_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default null
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default null
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default null
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default null
  ,p_mx_cvg_incr_alwd_amt           in  number    default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_cvg_mlt_incr_num            in  number    default null
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default null
  ,p_mx_cvg_rl                      in  number    default null
  ,p_mx_cvg_wcfn_amt                in  number    default null
  ,p_mx_cvg_wcfn_mlt_num            in  number    default null
  ,p_mn_cvg_amt                     in  number    default null
  ,p_mn_cvg_rl                      in  number    default null
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default null
  ,p_unsspnd_enrt_cd                in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_lbr_attribute_category         in  varchar2  default null
  ,p_lbr_attribute1                 in  varchar2  default null
  ,p_lbr_attribute2                 in  varchar2  default null
  ,p_lbr_attribute3                 in  varchar2  default null
  ,p_lbr_attribute4                 in  varchar2  default null
  ,p_lbr_attribute5                 in  varchar2  default null
  ,p_lbr_attribute6                 in  varchar2  default null
  ,p_lbr_attribute7                 in  varchar2  default null
  ,p_lbr_attribute8                 in  varchar2  default null
  ,p_lbr_attribute9                 in  varchar2  default null
  ,p_lbr_attribute10                in  varchar2  default null
  ,p_lbr_attribute11                in  varchar2  default null
  ,p_lbr_attribute12                in  varchar2  default null
  ,p_lbr_attribute13                in  varchar2  default null
  ,p_lbr_attribute14                in  varchar2  default null
  ,p_lbr_attribute15                in  varchar2  default null
  ,p_lbr_attribute16                in  varchar2  default null
  ,p_lbr_attribute17                in  varchar2  default null
  ,p_lbr_attribute18                in  varchar2  default null
  ,p_lbr_attribute19                in  varchar2  default null
  ,p_lbr_attribute20                in  varchar2  default null
  ,p_lbr_attribute21                in  varchar2  default null
  ,p_lbr_attribute22                in  varchar2  default null
  ,p_lbr_attribute23                in  varchar2  default null
  ,p_lbr_attribute24                in  varchar2  default null
  ,p_lbr_attribute25                in  varchar2  default null
  ,p_lbr_attribute26                in  varchar2  default null
  ,p_lbr_attribute27                in  varchar2  default null
  ,p_lbr_attribute28                in  varchar2  default null
  ,p_lbr_attribute29                in  varchar2  default null
  ,p_lbr_attribute30                in  varchar2  default null
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_LER_BNFT_RSTRN >------------------------|
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
--   p_ler_bnft_rstrn_id            Yes  number    PK of record
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_mn_cvg_amt                   No   number
--   p_mn_cvg_rl                    No   number
--   p_cvg_incr_r_decr_only_cd      No   varchar2
--   p_unsspnd_enrt_cd              No   varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   number
--   p_ler_id                       Yes  number
--   p_pl_id                        Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_plip_id                      Yes  number
--   p_lbr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_lbr_attribute1               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute2               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute3               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute4               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute5               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute6               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute7               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute8               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute9               No   varchar2  Descriptive Flexfield
--   p_lbr_attribute10              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute11              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute12              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute13              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute14              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute15              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute16              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute17              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute18              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute19              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute20              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute21              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute22              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute23              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute24              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute25              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute26              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute27              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute28              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute29              No   varchar2  Descriptive Flexfield
--   p_lbr_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_LER_BNFT_RSTRN
  (
   p_validate                       in boolean    default false
  ,p_ler_bnft_rstrn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default hr_api.g_number
  ,p_mx_cvg_incr_alwd_amt           in  number    default hr_api.g_number
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_num            in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default hr_api.g_number
  ,p_mx_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_mlt_num            in  number    default hr_api.g_number
  ,p_mn_cvg_amt                     in  number    default hr_api.g_number
  ,p_mn_cvg_rl                      in  number    default hr_api.g_number
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default hr_api.g_varchar2
  ,p_unsspnd_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_lbr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lbr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_LER_BNFT_RSTRN >------------------------|
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
--   p_ler_bnft_rstrn_id            Yes  number    PK of record
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
procedure delete_LER_BNFT_RSTRN
  (
   p_validate                       in boolean        default false
  ,p_ler_bnft_rstrn_id              in  number
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
--   p_ler_bnft_rstrn_id                 Yes  number   PK of record
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
    p_ler_bnft_rstrn_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_LER_BNFT_RSTRN_api;

 

/
