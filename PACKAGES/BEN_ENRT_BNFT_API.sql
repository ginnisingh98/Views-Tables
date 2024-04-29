--------------------------------------------------------
--  DDL for Package BEN_ENRT_BNFT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_BNFT_API" AUTHID CURRENT_USER as
/* $Header: beenbapi.pkh 120.0 2005/05/28 02:27:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_bnft >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_enrt_bnft_id                 Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_enrt_bnft
(
   p_validate                       in  boolean   default false
  ,p_enrt_bnft_id                   out nocopy number
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_val_has_bn_prortd_flag         in  varchar2  default 'N'
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default 'N'
  ,p_mn_val                         in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_incrmt_val                     in  number    default null
  ,p_dflt_val                       in  number    default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_cvg_mlt_cd                     in  varchar2  default null
  ,p_ctfn_rqd_flag                  in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_crntly_enrld_flag              in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_enb_attribute_category         in  varchar2  default null
  ,p_enb_attribute1                 in  varchar2  default null
  ,p_enb_attribute2                 in  varchar2  default null
  ,p_enb_attribute3                 in  varchar2  default null
  ,p_enb_attribute4                 in  varchar2  default null
  ,p_enb_attribute5                 in  varchar2  default null
  ,p_enb_attribute6                 in  varchar2  default null
  ,p_enb_attribute7                 in  varchar2  default null
  ,p_enb_attribute8                 in  varchar2  default null
  ,p_enb_attribute9                 in  varchar2  default null
  ,p_enb_attribute10                in  varchar2  default null
  ,p_enb_attribute11                in  varchar2  default null
  ,p_enb_attribute12                in  varchar2  default null
  ,p_enb_attribute13                in  varchar2  default null
  ,p_enb_attribute14                in  varchar2  default null
  ,p_enb_attribute15                in  varchar2  default null
  ,p_enb_attribute16                in  varchar2  default null
  ,p_enb_attribute17                in  varchar2  default null
  ,p_enb_attribute18                in  varchar2  default null
  ,p_enb_attribute19                in  varchar2  default null
  ,p_enb_attribute20                in  varchar2  default null
  ,p_enb_attribute21                in  varchar2  default null
  ,p_enb_attribute22                in  varchar2  default null
  ,p_enb_attribute23                in  varchar2  default null
  ,p_enb_attribute24                in  varchar2  default null
  ,p_enb_attribute25                in  varchar2  default null
  ,p_enb_attribute26                in  varchar2  default null
  ,p_enb_attribute27                in  varchar2  default null
  ,p_enb_attribute28                in  varchar2  default null
  ,p_enb_attribute29                in  varchar2  default null
  ,p_enb_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_mx_wout_ctfn_val               in number     default null
  ,p_mx_wo_ctfn_flag                in varchar2   default 'N'
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_bnft >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
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
procedure update_enrt_bnft
  (
   p_validate                       in  boolean   default false
  ,p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_mn_val                         in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_incrmt_val                     in  number    default hr_api.g_number
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_cvg_mlt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_crntly_enrld_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_mx_wout_ctfn_val               in number     default hr_api.g_number
  ,p_mx_wo_ctfn_flag                in varchar2   default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_bnft >------------------------|
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
--   p_enrt_bnft_id                 Yes  number    PK of record
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
procedure delete_enrt_bnft
  (
   p_validate                       in boolean        default false
  ,p_enrt_bnft_id                   in  number
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
--   p_enrt_bnft_id                 Yes  number   PK of record
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
    p_enrt_bnft_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_enrt_bnft_api;

 

/
