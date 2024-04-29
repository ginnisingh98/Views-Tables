--------------------------------------------------------
--  DDL for Package BEN_COMP_COMM_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_COMM_TYPES_API" AUTHID CURRENT_USER as
/* $Header: becctapi.pkh 120.0 2005/05/28 00:58:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_comp_comm_types >------------------------|
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
--   p_desc_txt                     No   varchar2
--   p_cm_typ_rl                    No   number
--   p_cm_usg_cd                    No   varchar2
--   p_whnvr_trgrd_flag             Yes  varchar2
--   p_shrt_name                    No   varchar2
--   p_pc_kit_cd                    No   varchar2
--   p_trk_mlg_flag                 Yes  varchar2
--   p_mx_num_avlbl_val             No   number
--   p_to_be_sent_dt_cd             Yes  varchar2
--   p_to_be_sent_dt_rl             No   number
--   p_inspn_rqd_flag               Yes  varchar2
--   p_inspn_rqd_rl                 No   number
--   p_rcpent_cd                    No   varchar2
--   p_parnt_cm_typ_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cct_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cct_attribute1               No   varchar2  Descriptive Flexfield
--   p_cct_attribute10              No   varchar2  Descriptive Flexfield
--   p_cct_attribute11              No   varchar2  Descriptive Flexfield
--   p_cct_attribute12              No   varchar2  Descriptive Flexfield
--   p_cct_attribute13              No   varchar2  Descriptive Flexfield
--   p_cct_attribute14              No   varchar2  Descriptive Flexfield
--   p_cct_attribute15              No   varchar2  Descriptive Flexfield
--   p_cct_attribute16              No   varchar2  Descriptive Flexfield
--   p_cct_attribute17              No   varchar2  Descriptive Flexfield
--   p_cct_attribute18              No   varchar2  Descriptive Flexfield
--   p_cct_attribute19              No   varchar2  Descriptive Flexfield
--   p_cct_attribute2               No   varchar2  Descriptive Flexfield
--   p_cct_attribute20              No   varchar2  Descriptive Flexfield
--   p_cct_attribute21              No   varchar2  Descriptive Flexfield
--   p_cct_attribute22              No   varchar2  Descriptive Flexfield
--   p_cct_attribute23              No   varchar2  Descriptive Flexfield
--   p_cct_attribute24              No   varchar2  Descriptive Flexfield
--   p_cct_attribute25              No   varchar2  Descriptive Flexfield
--   p_cct_attribute26              No   varchar2  Descriptive Flexfield
--   p_cct_attribute27              No   varchar2  Descriptive Flexfield
--   p_cct_attribute28              No   varchar2  Descriptive Flexfield
--   p_cct_attribute29              No   varchar2  Descriptive Flexfield
--   p_cct_attribute3               No   varchar2  Descriptive Flexfield
--   p_cct_attribute30              No   varchar2  Descriptive Flexfield
--   p_cct_attribute4               No   varchar2  Descriptive Flexfield
--   p_cct_attribute5               No   varchar2  Descriptive Flexfield
--   p_cct_attribute6               No   varchar2  Descriptive Flexfield
--   p_cct_attribute7               No   varchar2  Descriptive Flexfield
--   p_cct_attribute8               No   varchar2  Descriptive Flexfield
--   p_cct_attribute9               No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_cm_typ_id                    Yes  number    PK of record
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
procedure create_comp_comm_types
  (p_validate                       in boolean    default false
  ,p_cm_typ_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_desc_txt                       in  varchar2  default null
  ,p_cm_typ_rl                      in  number    default null
  ,p_cm_usg_cd                      in  varchar2  default null
  ,p_whnvr_trgrd_flag               in  varchar2  default null
  ,p_shrt_name                      in  varchar2  default null
  ,p_pc_kit_cd                      in  varchar2  default null
  ,p_trk_mlg_flag                   in  varchar2  default null
  ,p_mx_num_avlbl_val               in  number    default null
  ,p_to_be_sent_dt_cd               in  varchar2  default null
  ,p_to_be_sent_dt_rl               in  number    default null
  ,p_inspn_rqd_flag                 in  varchar2  default null
  ,p_inspn_rqd_rl                   in  number    default null
  ,p_rcpent_cd                      in  varchar2  default null
  ,p_parnt_cm_typ_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cct_attribute_category         in  varchar2  default null
  ,p_cct_attribute1                 in  varchar2  default null
  ,p_cct_attribute10                in  varchar2  default null
  ,p_cct_attribute11                in  varchar2  default null
  ,p_cct_attribute12                in  varchar2  default null
  ,p_cct_attribute13                in  varchar2  default null
  ,p_cct_attribute14                in  varchar2  default null
  ,p_cct_attribute15                in  varchar2  default null
  ,p_cct_attribute16                in  varchar2  default null
  ,p_cct_attribute17                in  varchar2  default null
  ,p_cct_attribute18                in  varchar2  default null
  ,p_cct_attribute19                in  varchar2  default null
  ,p_cct_attribute2                 in  varchar2  default null
  ,p_cct_attribute20                in  varchar2  default null
  ,p_cct_attribute21                in  varchar2  default null
  ,p_cct_attribute22                in  varchar2  default null
  ,p_cct_attribute23                in  varchar2  default null
  ,p_cct_attribute24                in  varchar2  default null
  ,p_cct_attribute25                in  varchar2  default null
  ,p_cct_attribute26                in  varchar2  default null
  ,p_cct_attribute27                in  varchar2  default null
  ,p_cct_attribute28                in  varchar2  default null
  ,p_cct_attribute29                in  varchar2  default null
  ,p_cct_attribute3                 in  varchar2  default null
  ,p_cct_attribute30                in  varchar2  default null
  ,p_cct_attribute4                 in  varchar2  default null
  ,p_cct_attribute5                 in  varchar2  default null
  ,p_cct_attribute6                 in  varchar2  default null
  ,p_cct_attribute7                 in  varchar2  default null
  ,p_cct_attribute8                 in  varchar2  default null
  ,p_cct_attribute9                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_comp_comm_types >------------------------|
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
--   p_cm_typ_id                    Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_desc_txt                     No   varchar2
--   p_cm_typ_rl                    No   number
--   p_cm_usg_cd                    No   varchar2
--   p_whnvr_trgrd_flag             Yes  varchar2
--   p_shrt_name                    No   varchar2
--   p_pc_kit_cd                    No   varchar2
--   p_trk_mlg_flag                 Yes  varchar2
--   p_mx_num_avlbl_val             No   number
--   p_to_be_sent_dt_cd             Yes  varchar2
--   p_to_be_sent_dt_rl             No   number
--   p_inspn_rqd_flag               Yes  varchar2
--   p_inspn_rqd_rl                 No   number
--   p_rcpent_cd                    No   varchar2
--   p_parnt_cm_typ_id              No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_cct_attribute_category       No   varchar2  Descriptive Flexfield
--   p_cct_attribute1               No   varchar2  Descriptive Flexfield
--   p_cct_attribute10              No   varchar2  Descriptive Flexfield
--   p_cct_attribute11              No   varchar2  Descriptive Flexfield
--   p_cct_attribute12              No   varchar2  Descriptive Flexfield
--   p_cct_attribute13              No   varchar2  Descriptive Flexfield
--   p_cct_attribute14              No   varchar2  Descriptive Flexfield
--   p_cct_attribute15              No   varchar2  Descriptive Flexfield
--   p_cct_attribute16              No   varchar2  Descriptive Flexfield
--   p_cct_attribute17              No   varchar2  Descriptive Flexfield
--   p_cct_attribute18              No   varchar2  Descriptive Flexfield
--   p_cct_attribute19              No   varchar2  Descriptive Flexfield
--   p_cct_attribute2               No   varchar2  Descriptive Flexfield
--   p_cct_attribute20              No   varchar2  Descriptive Flexfield
--   p_cct_attribute21              No   varchar2  Descriptive Flexfield
--   p_cct_attribute22              No   varchar2  Descriptive Flexfield
--   p_cct_attribute23              No   varchar2  Descriptive Flexfield
--   p_cct_attribute24              No   varchar2  Descriptive Flexfield
--   p_cct_attribute25              No   varchar2  Descriptive Flexfield
--   p_cct_attribute26              No   varchar2  Descriptive Flexfield
--   p_cct_attribute27              No   varchar2  Descriptive Flexfield
--   p_cct_attribute28              No   varchar2  Descriptive Flexfield
--   p_cct_attribute29              No   varchar2  Descriptive Flexfield
--   p_cct_attribute3               No   varchar2  Descriptive Flexfield
--   p_cct_attribute30              No   varchar2  Descriptive Flexfield
--   p_cct_attribute4               No   varchar2  Descriptive Flexfield
--   p_cct_attribute5               No   varchar2  Descriptive Flexfield
--   p_cct_attribute6               No   varchar2  Descriptive Flexfield
--   p_cct_attribute7               No   varchar2  Descriptive Flexfield
--   p_cct_attribute8               No   varchar2  Descriptive Flexfield
--   p_cct_attribute9               No   varchar2  Descriptive Flexfield
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
procedure update_comp_comm_types
  (p_validate                       in boolean    default false
  ,p_cm_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_desc_txt                       in  varchar2  default hr_api.g_varchar2
  ,p_cm_typ_rl                      in  number    default hr_api.g_number
  ,p_cm_usg_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_whnvr_trgrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_shrt_name                      in  varchar2  default hr_api.g_varchar2
  ,p_pc_kit_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_trk_mlg_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_mx_num_avlbl_val               in  number    default hr_api.g_number
  ,p_to_be_sent_dt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_to_be_sent_dt_rl               in  number    default hr_api.g_number
  ,p_inspn_rqd_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_inspn_rqd_rl                   in  number    default hr_api.g_number
  ,p_rcpent_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_parnt_cm_typ_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cct_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_comp_comm_types >------------------------|
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
--   p_cm_typ_id                    Yes  number    PK of record
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
procedure delete_comp_comm_types
  (p_validate                       in boolean        default false
  ,p_cm_typ_id                      in  number
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
--   p_cm_typ_id                 Yes  number   PK of record
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
  (p_cm_typ_id                 in number
  ,p_object_version_number     in number
  ,p_effective_date            in date
  ,p_datetrack_mode            in varchar2
  ,p_validation_start_date     out nocopy date
  ,p_validation_end_date       out nocopy date);
--
end ben_comp_comm_types_api;

 

/
