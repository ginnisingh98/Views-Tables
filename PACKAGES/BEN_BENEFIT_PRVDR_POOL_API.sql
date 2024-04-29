--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_PRVDR_POOL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_PRVDR_POOL_API" AUTHID CURRENT_USER as
/* $Header: bebppapi.pkh 120.0 2005/05/28 00:48:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdr_Pool >------------------------|
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
--   p_pgm_pool_flag                Yes  varchar2
--   p_excs_alwys_fftd_flag         Yes  varchar2
--   p_use_for_pgm_pool_flag        Yes  varchar2
--   p_pct_rndg_cd                  No   varchar2
--   p_pct_rndg_rl                  No   number
--   p_val_rndg_cd                  No   varchar2
--   p_val_rndg_rl                  No   number
--   p_dflt_excs_trtmt_cd           No   varchar2
--   p_dflt_excs_trtmt_rl           No   number
--   p_rlovr_rstrcn_cd              No   varchar2
--   p_no_mn_dstrbl_pct_flag        Yes  varchar2
--   p_no_mn_dstrbl_val_flag        Yes  varchar2
--   p_no_mx_dstrbl_pct_flag        Yes  varchar2
--   p_no_mx_dstrbl_val_flag        Yes  varchar2
--   p_auto_alct_excs_flag          Yes  varchar2
--   p_alws_ngtv_crs_flag           Yes  varchar2
--   p_uses_net_crs_mthd_flag       Yes  vatchar2
--   p_mx_dfcit_pct_pool_crs_num    No   Number
--   p_mx_dfcit_pct_comp_num        No   Number
--   p_comp_lvl_fctr_id             No   Number
--   p_mn_dstrbl_pct_num            No   number
--   p_mn_dstrbl_val                No   number
--   p_mx_dstrbl_pct_num            No   number
--   p_mx_dstrbl_val                No   number
--   p_excs_trtmt_cd                No   varchar2
--   p_ptip_id                      No   number
--   p_plip_id                      No   number
--   p_pgm_id                       Yes  number
--   p_oiplip_id                    No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_bpp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bpp_attribute1               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute2               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute3               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute4               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute5               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute6               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute7               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute8               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute9               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute10              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute11              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute12              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute13              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute14              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute15              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute16              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute17              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute18              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute19              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute20              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute21              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute22              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute23              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute24              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute25              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute26              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute27              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute28              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute29              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_bnft_prvdr_pool_id           Yes  number    PK of record
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
procedure create_Benefit_Prvdr_Pool
(
   p_validate                       in boolean    default false
  ,p_bnft_prvdr_pool_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_pgm_pool_flag                  in  varchar2  default 'N'
  ,p_excs_alwys_fftd_flag           in  varchar2  default 'N'
  ,p_use_for_pgm_pool_flag          in  varchar2  default 'N'
  ,p_pct_rndg_cd                    in  varchar2  default null
  ,p_pct_rndg_rl                    in  number    default null
  ,p_val_rndg_cd                    in  varchar2  default null
  ,p_val_rndg_rl                    in  number    default null
  ,p_dflt_excs_trtmt_cd             in  varchar2  default null
  ,p_dflt_excs_trtmt_rl             in  number  default null
  ,p_rlovr_rstrcn_cd                in  varchar2  default null
  ,p_no_mn_dstrbl_pct_flag          in  varchar2  default 'N'
  ,p_no_mn_dstrbl_val_flag          in  varchar2  default 'N'
  ,p_no_mx_dstrbl_pct_flag          in  varchar2  default 'N'
  ,p_no_mx_dstrbl_val_flag          in  varchar2  default 'N'
  ,p_auto_alct_excs_flag            in  varchar2  default 'N'
  ,p_alws_ngtv_crs_flag             in  varchar2  default 'N'
  ,p_uses_net_crs_mthd_flag         in  varchar2  default 'N'
  ,p_mx_dfcit_pct_pool_crs_num      in  number    default null
  ,p_mx_dfcit_pct_comp_num          in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_mn_dstrbl_pct_num              in  number    default null
  ,p_mn_dstrbl_val                  in  number    default null
  ,p_mx_dstrbl_pct_num              in  number    default null
  ,p_mx_dstrbl_val                  in  number    default null
  ,p_excs_trtmt_cd                  in  varchar2  default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bpp_attribute_category         in  varchar2  default null
  ,p_bpp_attribute1                 in  varchar2  default null
  ,p_bpp_attribute2                 in  varchar2  default null
  ,p_bpp_attribute3                 in  varchar2  default null
  ,p_bpp_attribute4                 in  varchar2  default null
  ,p_bpp_attribute5                 in  varchar2  default null
  ,p_bpp_attribute6                 in  varchar2  default null
  ,p_bpp_attribute7                 in  varchar2  default null
  ,p_bpp_attribute8                 in  varchar2  default null
  ,p_bpp_attribute9                 in  varchar2  default null
  ,p_bpp_attribute10                in  varchar2  default null
  ,p_bpp_attribute11                in  varchar2  default null
  ,p_bpp_attribute12                in  varchar2  default null
  ,p_bpp_attribute13                in  varchar2  default null
  ,p_bpp_attribute14                in  varchar2  default null
  ,p_bpp_attribute15                in  varchar2  default null
  ,p_bpp_attribute16                in  varchar2  default null
  ,p_bpp_attribute17                in  varchar2  default null
  ,p_bpp_attribute18                in  varchar2  default null
  ,p_bpp_attribute19                in  varchar2  default null
  ,p_bpp_attribute20                in  varchar2  default null
  ,p_bpp_attribute21                in  varchar2  default null
  ,p_bpp_attribute22                in  varchar2  default null
  ,p_bpp_attribute23                in  varchar2  default null
  ,p_bpp_attribute24                in  varchar2  default null
  ,p_bpp_attribute25                in  varchar2  default null
  ,p_bpp_attribute26                in  varchar2  default null
  ,p_bpp_attribute27                in  varchar2  default null
  ,p_bpp_attribute28                in  varchar2  default null
  ,p_bpp_attribute29                in  varchar2  default null
  ,p_bpp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdr_Pool >------------------------|
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
--   p_bnft_prvdr_pool_id           Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_pgm_pool_flag                Yes  varchar2
--   p_excs_alwys_fftd_flag         Yes  varchar2
--   p_use_for_pgm_pool_flag        Yes  varchar2
--   p_pct_rndg_cd                  No   varchar2
--   p_pct_rndg_rl                  No   number
--   p_val_rndg_cd                  No   varchar2
--   p_val_rndg_rl                  No   number
--   p_dflt_excs_trtmt_cd           No   varchar2
--   p_dflt_excs_trtmt_rl           No   number
--   p_rlovr_rstrcn_cd              No   varchar2
--   p_no_mn_dstrbl_pct_flag        Yes  varchar2
--   p_no_mn_dstrbl_val_flag        Yes  varchar2
--   p_no_mx_dstrbl_pct_flag        Yes  varchar2
--   p_no_mx_dstrbl_val_flag        Yes  varchar2
--   p_auto_alct_excs_flag          Yes  varchar2
--   p_alws_ngtv_crs_flag           Yes  varchar2
--   p_uses_net_crs_mthd_flag       Yes  vatchar2
--   p_mx_dfcit_pct_pool_crs_num    No   Number
--   p_mx_dfcit_pct_comp_num        No   Number
--   p_comp_lvl_fctr_id             No   Number
--   p_mn_dstrbl_pct_num            No   number
--   p_mn_dstrbl_val                No   number
--   p_mx_dstrbl_pct_num            No   number
--   p_mx_dstrbl_val                No   number
--   p_excs_trtmt_cd                No   varchar2
--   p_ptip_id                      No   number
--   p_plip_id                      No   number
--   p_pgm_id                       Yes  number
--   p_oiplip_id                    No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_bpp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bpp_attribute1               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute2               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute3               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute4               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute5               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute6               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute7               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute8               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute9               No   varchar2  Descriptive Flexfield
--   p_bpp_attribute10              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute11              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute12              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute13              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute14              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute15              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute16              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute17              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute18              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute19              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute20              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute21              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute22              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute23              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute24              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute25              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute26              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute27              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute28              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute29              No   varchar2  Descriptive Flexfield
--   p_bpp_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_Benefit_Prvdr_Pool
  (
   p_validate                       in boolean    default false
  ,p_bnft_prvdr_pool_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_pgm_pool_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_excs_alwys_fftd_flag           in  varchar2  default hr_api.g_varchar2
  ,p_use_for_pgm_pool_flag          in  varchar2  default hr_api.g_varchar2
  ,p_pct_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pct_rndg_rl                    in  number    default hr_api.g_number
  ,p_val_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_val_rndg_rl                    in  number    default hr_api.g_number
  ,p_dflt_excs_trtmt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dflt_excs_trtmt_rl             in  number    default hr_api.g_number
  ,p_rlovr_rstrcn_cd                in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_dstrbl_pct_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_dstrbl_val_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_dstrbl_pct_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_dstrbl_val_flag          in  varchar2  default hr_api.g_varchar2
  ,p_auto_alct_excs_flag            in  varchar2  default hr_api.g_varchar2
  ,p_alws_ngtv_crs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_uses_net_crs_mthd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_mx_dfcit_pct_pool_crs_num      in  number    default hr_api.g_number
  ,p_mx_dfcit_pct_comp_num          in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_mn_dstrbl_pct_num              in  number    default hr_api.g_number
  ,p_mn_dstrbl_val                  in  number    default hr_api.g_number
  ,p_mx_dstrbl_pct_num              in  number    default hr_api.g_number
  ,p_mx_dstrbl_val                  in  number    default hr_api.g_number
  ,p_excs_trtmt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bpp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdr_Pool >------------------------|
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
--   p_bnft_prvdr_pool_id           Yes  number    PK of record
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
procedure delete_Benefit_Prvdr_Pool
  (
   p_validate                       in boolean        default false
  ,p_bnft_prvdr_pool_id             in  number
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
--   p_bnft_prvdr_pool_id                 Yes  number   PK of record
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
    p_bnft_prvdr_pool_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Benefit_Prvdr_Pool_api;

 

/
