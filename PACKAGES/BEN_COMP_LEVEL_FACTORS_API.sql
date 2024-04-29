--------------------------------------------------------
--  DDL for Package BEN_COMP_LEVEL_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_LEVEL_FACTORS_API" AUTHID CURRENT_USER as
/* $Header: beclfapi.pkh 120.0 2005/05/28 01:03:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_comp_level_factors >---------------------|
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
--   p_comp_lvl_det_cd              No   varchar2
--   p_comp_lvl_det_rl              No   number
--   p_comp_lvl_uom                 No   varchar2
--   p_comp_src_cd                  No   varchar2
--   p_no_mn_comp_flag              Yes  varchar2
--   p_no_mx_comp_flag              Yes  varchar2
--   p_mx_comp_val                  No   number
--   p_mn_comp_val                  No   number
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_defined_balance_id           No   number
--   p_bnfts_bal_id                 No   number
--   p_sttd_sal_prdcty_cd           No   varchar2
--   p_comp_alt_val_to_use_cd       No   varchar2
--   p_comp_calc_rl                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_clf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_clf_attribute1               No   varchar2  Descriptive Flexfield
--   p_clf_attribute2               No   varchar2  Descriptive Flexfield
--   p_clf_attribute3               No   varchar2  Descriptive Flexfield
--   p_clf_attribute4               No   varchar2  Descriptive Flexfield
--   p_clf_attribute5               No   varchar2  Descriptive Flexfield
--   p_clf_attribute6               No   varchar2  Descriptive Flexfield
--   p_clf_attribute7               No   varchar2  Descriptive Flexfield
--   p_clf_attribute8               No   varchar2  Descriptive Flexfield
--   p_clf_attribute9               No   varchar2  Descriptive Flexfield
--   p_clf_attribute10              No   varchar2  Descriptive Flexfield
--   p_clf_attribute11              No   varchar2  Descriptive Flexfield
--   p_clf_attribute12              No   varchar2  Descriptive Flexfield
--   p_clf_attribute13              No   varchar2  Descriptive Flexfield
--   p_clf_attribute14              No   varchar2  Descriptive Flexfield
--   p_clf_attribute15              No   varchar2  Descriptive Flexfield
--   p_clf_attribute16              No   varchar2  Descriptive Flexfield
--   p_clf_attribute17              No   varchar2  Descriptive Flexfield
--   p_clf_attribute18              No   varchar2  Descriptive Flexfield
--   p_clf_attribute19              No   varchar2  Descriptive Flexfield
--   p_clf_attribute20              No   varchar2  Descriptive Flexfield
--   p_clf_attribute21              No   varchar2  Descriptive Flexfield
--   p_clf_attribute22              No   varchar2  Descriptive Flexfield
--   p_clf_attribute23              No   varchar2  Descriptive Flexfield
--   p_clf_attribute24              No   varchar2  Descriptive Flexfield
--   p_clf_attribute25              No   varchar2  Descriptive Flexfield
--   p_clf_attribute26              No   varchar2  Descriptive Flexfield
--   p_clf_attribute27              No   varchar2  Descriptive Flexfield
--   p_clf_attribute28              No   varchar2  Descriptive Flexfield
--   p_clf_attribute29              No   varchar2  Descriptive Flexfield
--   p_clf_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_comp_lvl_fctr_id             Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_comp_level_factors
(
   p_validate                       in boolean    default false
  ,p_comp_lvl_fctr_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_comp_lvl_det_cd                in  varchar2  default null
  ,p_comp_lvl_det_rl                in  number    default null
  ,p_comp_lvl_uom                   in  varchar2  default null
  ,p_comp_src_cd                    in  varchar2  default null
  ,p_no_mn_comp_flag                in  varchar2  default null
  ,p_no_mx_comp_flag                in  varchar2  default null
  ,p_mx_comp_val                    in  number    default null
  ,p_mn_comp_val                    in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_defined_balance_id             in  number    default null
  ,p_bnfts_bal_id                   in  number    default null
  ,p_comp_alt_val_to_use_cd         in  varchar2  default null
  ,p_comp_calc_rl                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_proration_flag                 in Varchar2   default 'N'
  ,p_start_day_mo                   in Varchar2   default null
  ,p_end_day_mo                     in Varchar2   default null
  ,p_start_year                     in Varchar2   default null
  ,p_end_year                       in Varchar2   default null
  ,p_clf_attribute_category         in  varchar2  default null
  ,p_clf_attribute1                 in  varchar2  default null
  ,p_clf_attribute2                 in  varchar2  default null
  ,p_clf_attribute3                 in  varchar2  default null
  ,p_clf_attribute4                 in  varchar2  default null
  ,p_clf_attribute5                 in  varchar2  default null
  ,p_clf_attribute6                 in  varchar2  default null
  ,p_clf_attribute7                 in  varchar2  default null
  ,p_clf_attribute8                 in  varchar2  default null
  ,p_clf_attribute9                 in  varchar2  default null
  ,p_clf_attribute10                in  varchar2  default null
  ,p_clf_attribute11                in  varchar2  default null
  ,p_clf_attribute12                in  varchar2  default null
  ,p_clf_attribute13                in  varchar2  default null
  ,p_clf_attribute14                in  varchar2  default null
  ,p_clf_attribute15                in  varchar2  default null
  ,p_clf_attribute16                in  varchar2  default null
  ,p_clf_attribute17                in  varchar2  default null
  ,p_clf_attribute18                in  varchar2  default null
  ,p_clf_attribute19                in  varchar2  default null
  ,p_clf_attribute20                in  varchar2  default null
  ,p_clf_attribute21                in  varchar2  default null
  ,p_clf_attribute22                in  varchar2  default null
  ,p_clf_attribute23                in  varchar2  default null
  ,p_clf_attribute24                in  varchar2  default null
  ,p_clf_attribute25                in  varchar2  default null
  ,p_clf_attribute26                in  varchar2  default null
  ,p_clf_attribute27                in  varchar2  default null
  ,p_clf_attribute28                in  varchar2  default null
  ,p_clf_attribute29                in  varchar2  default null
  ,p_clf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2  default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_comp_level_factors >------------------------|
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
--   p_comp_lvl_fctr_id             Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_comp_lvl_det_cd              No   varchar2
--   p_comp_lvl_det_rl              No   number
--   p_comp_lvl_uom                 No   varchar2
--   p_comp_src_cd                  No   varchar2
--   p_no_mn_comp_flag              Yes  varchar2
--   p_no_mx_comp_flag              Yes  varchar2
--   p_mx_comp_val                  No   number
--   p_mn_comp_val                  No   number
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_defined_balance_id           No   number
--   p_bnfts_bal_id                 No   number
--   p_sttd_sal_prdcty_cd           No   varchar2
--   p_comp_alt_val_to_use_cd       No   varchar2
--   p_comp_calc_rl                 No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_clf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_clf_attribute1               No   varchar2  Descriptive Flexfield
--   p_clf_attribute2               No   varchar2  Descriptive Flexfield
--   p_clf_attribute3               No   varchar2  Descriptive Flexfield
--   p_clf_attribute4               No   varchar2  Descriptive Flexfield
--   p_clf_attribute5               No   varchar2  Descriptive Flexfield
--   p_clf_attribute6               No   varchar2  Descriptive Flexfield
--   p_clf_attribute7               No   varchar2  Descriptive Flexfield
--   p_clf_attribute8               No   varchar2  Descriptive Flexfield
--   p_clf_attribute9               No   varchar2  Descriptive Flexfield
--   p_clf_attribute10              No   varchar2  Descriptive Flexfield
--   p_clf_attribute11              No   varchar2  Descriptive Flexfield
--   p_clf_attribute12              No   varchar2  Descriptive Flexfield
--   p_clf_attribute13              No   varchar2  Descriptive Flexfield
--   p_clf_attribute14              No   varchar2  Descriptive Flexfield
--   p_clf_attribute15              No   varchar2  Descriptive Flexfield
--   p_clf_attribute16              No   varchar2  Descriptive Flexfield
--   p_clf_attribute17              No   varchar2  Descriptive Flexfield
--   p_clf_attribute18              No   varchar2  Descriptive Flexfield
--   p_clf_attribute19              No   varchar2  Descriptive Flexfield
--   p_clf_attribute20              No   varchar2  Descriptive Flexfield
--   p_clf_attribute21              No   varchar2  Descriptive Flexfield
--   p_clf_attribute22              No   varchar2  Descriptive Flexfield
--   p_clf_attribute23              No   varchar2  Descriptive Flexfield
--   p_clf_attribute24              No   varchar2  Descriptive Flexfield
--   p_clf_attribute25              No   varchar2  Descriptive Flexfield
--   p_clf_attribute26              No   varchar2  Descriptive Flexfield
--   p_clf_attribute27              No   varchar2  Descriptive Flexfield
--   p_clf_attribute28              No   varchar2  Descriptive Flexfield
--   p_clf_attribute29              No   varchar2  Descriptive Flexfield
--   p_clf_attribute30              No   varchar2  Descriptive Flexfield
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
procedure update_comp_level_factors
  (
   p_validate                       in boolean    default false
  ,p_comp_lvl_fctr_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_det_rl                in  number    default hr_api.g_number
  ,p_comp_lvl_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_comp_src_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_comp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_comp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_mx_comp_val                    in  number    default hr_api.g_number
  ,p_mn_comp_val                    in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_defined_balance_id             in  number    default hr_api.g_number
  ,p_bnfts_bal_id                   in  number    default hr_api.g_number
  ,p_comp_alt_val_to_use_cd         in  varchar2  default hr_api.g_varchar2
  ,p_comp_calc_rl                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_proration_flag                 in Varchar2   default hr_api.g_varchar2
  ,p_start_day_mo                   in Varchar2   default hr_api.g_varchar2
  ,p_end_day_mo                     in Varchar2   default hr_api.g_varchar2
  ,p_start_year                     in Varchar2   default hr_api.g_varchar2
  ,p_end_year                       in Varchar2   default hr_api.g_varchar2
  ,p_clf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_comp_level_factors >------------------------|
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
--   p_comp_lvl_fctr_id             Yes  number    PK of record
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
procedure delete_comp_level_factors
  (
   p_validate                       in boolean        default false
  ,p_comp_lvl_fctr_id               in  number
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
--   p_comp_lvl_fctr_id                 Yes  number   PK of record
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
    p_comp_lvl_fctr_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_comp_level_factors_api;

 

/
