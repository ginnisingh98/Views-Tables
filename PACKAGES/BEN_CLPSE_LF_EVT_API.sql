--------------------------------------------------------
--  DDL for Package BEN_CLPSE_LF_EVT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLPSE_LF_EVT_API" AUTHID CURRENT_USER as
/* $Header: beclpapi.pkh 120.0 2005/05/28 01:04:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_clpse_lf_evt >---------------------------|
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
--   p_seq                          Yes  number
--   p_ler1_id                      No   number
--   p_bool1_cd                     No   varchar2
--   p_ler2_id                      No   number
--   p_bool2_cd                     No   varchar2
--   p_ler3_id                      No   number
--   p_bool3_cd                     No   varchar2
--   p_ler4_id                      No   number
--   p_bool4_cd                     No   varchar2
--   p_ler5_id                      No   number
--   p_bool5_cd                     No   varchar2
--   p_ler6_id                      No   number
--   p_bool6_cd                     No   varchar2
--   p_ler7_id                      No   number
--   p_bool7_cd                     No   varchar2
--   p_ler8_id                      No   number
--   p_bool8_cd                     No   varchar2
--   p_ler9_id                      No   number
--   p_bool9_cd                     No   varchar2
--   p_ler10_id                     No   number
--   p_eval_cd                      Yes  varchar2
--   p_eval_rl                      No   number
--   p_tlrnc_dys_num                No   number
--   p_eval_ler_id                  Yes  number
--   p_eval_ler_det_cd              Yes  varchar2
--   p_eval_ler_det_rl              No   number
--   p_clp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_clp_attribute1               No   varchar2  Descriptive Flexfield
--   p_clp_attribute2               No   varchar2  Descriptive Flexfield
--   p_clp_attribute3               No   varchar2  Descriptive Flexfield
--   p_clp_attribute4               No   varchar2  Descriptive Flexfield
--   p_clp_attribute5               No   varchar2  Descriptive Flexfield
--   p_clp_attribute6               No   varchar2  Descriptive Flexfield
--   p_clp_attribute7               No   varchar2  Descriptive Flexfield
--   p_clp_attribute8               No   varchar2  Descriptive Flexfield
--   p_clp_attribute9               No   varchar2  Descriptive Flexfield
--   p_clp_attribute10              No   varchar2  Descriptive Flexfield
--   p_clp_attribute11              No   varchar2  Descriptive Flexfield
--   p_clp_attribute12              No   varchar2  Descriptive Flexfield
--   p_clp_attribute13              No   varchar2  Descriptive Flexfield
--   p_clp_attribute14              No   varchar2  Descriptive Flexfield
--   p_clp_attribute15              No   varchar2  Descriptive Flexfield
--   p_clp_attribute16              No   varchar2  Descriptive Flexfield
--   p_clp_attribute17              No   varchar2  Descriptive Flexfield
--   p_clp_attribute18              No   varchar2  Descriptive Flexfield
--   p_clp_attribute19              No   varchar2  Descriptive Flexfield
--   p_clp_attribute20              No   varchar2  Descriptive Flexfield
--   p_clp_attribute21              No   varchar2  Descriptive Flexfield
--   p_clp_attribute22              No   varchar2  Descriptive Flexfield
--   p_clp_attribute23              No   varchar2  Descriptive Flexfield
--   p_clp_attribute24              No   varchar2  Descriptive Flexfield
--   p_clp_attribute25              No   varchar2  Descriptive Flexfield
--   p_clp_attribute26              No   varchar2  Descriptive Flexfield
--   p_clp_attribute27              No   varchar2  Descriptive Flexfield
--   p_clp_attribute28              No   varchar2  Descriptive Flexfield
--   p_clp_attribute29              No   varchar2  Descriptive Flexfield
--   p_clp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_clpse_lf_evt_id              Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_clpse_lf_evt
  (p_validate                       in boolean    default false
  ,p_clpse_lf_evt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_seq                            in  number    default null
  ,p_ler1_id                        in  number    default null
  ,p_bool1_cd                       in  varchar2  default null
  ,p_ler2_id                        in  number    default null
  ,p_bool2_cd                       in  varchar2  default null
  ,p_ler3_id                        in  number    default null
  ,p_bool3_cd                       in  varchar2  default null
  ,p_ler4_id                        in  number    default null
  ,p_bool4_cd                       in  varchar2  default null
  ,p_ler5_id                        in  number    default null
  ,p_bool5_cd                       in  varchar2  default null
  ,p_ler6_id                        in  number    default null
  ,p_bool6_cd                       in  varchar2  default null
  ,p_ler7_id                        in  number    default null
  ,p_bool7_cd                       in  varchar2  default null
  ,p_ler8_id                        in  number    default null
  ,p_bool8_cd                       in  varchar2  default null
  ,p_ler9_id                        in  number    default null
  ,p_bool9_cd                       in  varchar2  default null
  ,p_ler10_id                       in  number    default null
  ,p_eval_cd                        in  varchar2  default null
  ,p_eval_rl                        in  number    default null
  ,p_tlrnc_dys_num                  in  number    default null
  ,p_eval_ler_id                    in  number    default null
  ,p_eval_ler_det_cd                in  varchar2  default null
  ,p_eval_ler_det_rl                in  number    default null
  ,p_clp_attribute_category         in  varchar2  default null
  ,p_clp_attribute1                 in  varchar2  default null
  ,p_clp_attribute2                 in  varchar2  default null
  ,p_clp_attribute3                 in  varchar2  default null
  ,p_clp_attribute4                 in  varchar2  default null
  ,p_clp_attribute5                 in  varchar2  default null
  ,p_clp_attribute6                 in  varchar2  default null
  ,p_clp_attribute7                 in  varchar2  default null
  ,p_clp_attribute8                 in  varchar2  default null
  ,p_clp_attribute9                 in  varchar2  default null
  ,p_clp_attribute10                in  varchar2  default null
  ,p_clp_attribute11                in  varchar2  default null
  ,p_clp_attribute12                in  varchar2  default null
  ,p_clp_attribute13                in  varchar2  default null
  ,p_clp_attribute14                in  varchar2  default null
  ,p_clp_attribute15                in  varchar2  default null
  ,p_clp_attribute16                in  varchar2  default null
  ,p_clp_attribute17                in  varchar2  default null
  ,p_clp_attribute18                in  varchar2  default null
  ,p_clp_attribute19                in  varchar2  default null
  ,p_clp_attribute20                in  varchar2  default null
  ,p_clp_attribute21                in  varchar2  default null
  ,p_clp_attribute22                in  varchar2  default null
  ,p_clp_attribute23                in  varchar2  default null
  ,p_clp_attribute24                in  varchar2  default null
  ,p_clp_attribute25                in  varchar2  default null
  ,p_clp_attribute26                in  varchar2  default null
  ,p_clp_attribute27                in  varchar2  default null
  ,p_clp_attribute28                in  varchar2  default null
  ,p_clp_attribute29                in  varchar2  default null
  ,p_clp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_clpse_lf_evt >---------------------------|
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
--   p_clpse_lf_evt_id              Yes  number    PK of record
--   p_business_group_id            Yes  number    Business Group of Record
--   p_seq                          Yes  number
--   p_ler1_id                      No   number
--   p_bool1_cd                     No   varchar2
--   p_ler2_id                      No   number
--   p_bool2_cd                     No   varchar2
--   p_ler3_id                      No   number
--   p_bool3_cd                     No   varchar2
--   p_ler4_id                      No   number
--   p_bool4_cd                     No   varchar2
--   p_ler5_id                      No   number
--   p_bool5_cd                     No   varchar2
--   p_ler6_id                      No   number
--   p_bool6_cd                     No   varchar2
--   p_ler7_id                      No   number
--   p_bool7_cd                     No   varchar2
--   p_ler8_id                      No   number
--   p_bool8_cd                     No   varchar2
--   p_ler9_id                      No   number
--   p_bool9_cd                     No   varchar2
--   p_ler10_id                     No   number
--   p_eval_cd                      Yes  varchar2
--   p_eval_rl                      No   number
--   p_tlrnc_dys_num                No   number
--   p_eval_ler_id                  Yes  number
--   p_eval_ler_det_cd              Yes  varchar2
--   p_eval_ler_det_rl              No   number
--   p_clp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_clp_attribute1               No   varchar2  Descriptive Flexfield
--   p_clp_attribute2               No   varchar2  Descriptive Flexfield
--   p_clp_attribute3               No   varchar2  Descriptive Flexfield
--   p_clp_attribute4               No   varchar2  Descriptive Flexfield
--   p_clp_attribute5               No   varchar2  Descriptive Flexfield
--   p_clp_attribute6               No   varchar2  Descriptive Flexfield
--   p_clp_attribute7               No   varchar2  Descriptive Flexfield
--   p_clp_attribute8               No   varchar2  Descriptive Flexfield
--   p_clp_attribute9               No   varchar2  Descriptive Flexfield
--   p_clp_attribute10              No   varchar2  Descriptive Flexfield
--   p_clp_attribute11              No   varchar2  Descriptive Flexfield
--   p_clp_attribute12              No   varchar2  Descriptive Flexfield
--   p_clp_attribute13              No   varchar2  Descriptive Flexfield
--   p_clp_attribute14              No   varchar2  Descriptive Flexfield
--   p_clp_attribute15              No   varchar2  Descriptive Flexfield
--   p_clp_attribute16              No   varchar2  Descriptive Flexfield
--   p_clp_attribute17              No   varchar2  Descriptive Flexfield
--   p_clp_attribute18              No   varchar2  Descriptive Flexfield
--   p_clp_attribute19              No   varchar2  Descriptive Flexfield
--   p_clp_attribute20              No   varchar2  Descriptive Flexfield
--   p_clp_attribute21              No   varchar2  Descriptive Flexfield
--   p_clp_attribute22              No   varchar2  Descriptive Flexfield
--   p_clp_attribute23              No   varchar2  Descriptive Flexfield
--   p_clp_attribute24              No   varchar2  Descriptive Flexfield
--   p_clp_attribute25              No   varchar2  Descriptive Flexfield
--   p_clp_attribute26              No   varchar2  Descriptive Flexfield
--   p_clp_attribute27              No   varchar2  Descriptive Flexfield
--   p_clp_attribute28              No   varchar2  Descriptive Flexfield
--   p_clp_attribute29              No   varchar2  Descriptive Flexfield
--   p_clp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_clpse_lf_evt
  (p_validate                       in  boolean    default false
  ,p_clpse_lf_evt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_seq                            in  number    default hr_api.g_number
  ,p_ler1_id                        in  number    default hr_api.g_number
  ,p_bool1_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler2_id                        in  number    default hr_api.g_number
  ,p_bool2_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler3_id                        in  number    default hr_api.g_number
  ,p_bool3_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler4_id                        in  number    default hr_api.g_number
  ,p_bool4_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler5_id                        in  number    default hr_api.g_number
  ,p_bool5_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler6_id                        in  number    default hr_api.g_number
  ,p_bool6_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler7_id                        in  number    default hr_api.g_number
  ,p_bool7_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler8_id                        in  number    default hr_api.g_number
  ,p_bool8_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler9_id                        in  number    default hr_api.g_number
  ,p_bool9_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler10_id                       in  number    default hr_api.g_number
  ,p_eval_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_eval_rl                        in  number    default hr_api.g_number
  ,p_tlrnc_dys_num                  in  number    default hr_api.g_number
  ,p_eval_ler_id                    in  number    default hr_api.g_number
  ,p_eval_ler_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_eval_ler_det_rl                in  number    default hr_api.g_number
  ,p_clp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_clpse_lf_evt >---------------------------|
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
--   p_clpse_lf_evt_id              Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_clpse_lf_evt
  (p_validate                       in boolean        default false
  ,p_clpse_lf_evt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
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
--   p_clpse_lf_evt_id                 Yes  number   PK of record
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
  (p_clpse_lf_evt_id             in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2
  ,p_validation_start_date       out nocopy date
  ,p_validation_end_date         out nocopy date);
--
end ben_clpse_lf_evt_api;

 

/
