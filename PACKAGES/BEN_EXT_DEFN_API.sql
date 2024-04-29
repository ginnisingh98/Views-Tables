--------------------------------------------------------
--  DDL for Package BEN_EXT_DEFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DEFN_API" AUTHID CURRENT_USER as
/* $Header: bexdfapi.pkh 120.2 2006/06/06 21:50:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_DEFN >------------------------|
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
--   p_name                         No   varchar2
--   p_data_typ_cd                  No   varchar2
--   p_ext_typ_cd                   No   varchar2
--   p_output_name                  No   varchar2
--   p_output_type                  No   varchar2
--   p_apnd_rqst_id_flag            Yes  varchar2
--   p_prmy_sort_cd                 No   varchar2
--   p_scnd_sort_cd                 No   varchar2
--   p_strt_dt                      No   varchar2
--   p_end_dt                       No   varchar2
--   p_ext_crit_prfl_id             No   number
--   p_ext_file_id                  No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_xdf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xdf_attribute1               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute2               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute3               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute4               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute5               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute6               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute7               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute8               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute9               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute10              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute11              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute12              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute13              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute14              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute15              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute16              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute17              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute18              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute19              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute20              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute21              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute22              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute23              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute24              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute25              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute26              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute27              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute28              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute29              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute30              No   varchar2  Descriptive Flexfield
--   p_drctry_name                  No   varchar2
--   p_kickoff_wrt_prc_flag         Yes  varchar2
--   p_upd_cm_sent_dt_flag          No   varchar2
--   p_spcl_hndl_flag               No   varchar2
--   p_ext_global_flag               No   varchar2
--   p_cm_display_flag               No   varchar2
--   p_use_eff_dt_for_chgs_flag     No   varchar2
--   p_ext_post_prcs_rl             No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ext_dfn_id                   Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_EXT_DEFN
(
   p_validate                       in boolean    default false
  ,p_ext_dfn_id                     out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_xml_tag_name                   in  varchar2  default null
  ,p_xdo_template_id                in  number    default null
  ,p_data_typ_cd                    in  varchar2  default null
  ,p_ext_typ_cd                     in  varchar2  default null
  ,p_output_name                    in  varchar2  default null
  ,p_output_type                    in  varchar2  default null
  ,p_apnd_rqst_id_flag              in  varchar2  default null
  ,p_prmy_sort_cd                   in  varchar2  default null
  ,p_scnd_sort_cd                   in  varchar2  default null
  ,p_strt_dt                        in  varchar2  default null
  ,p_end_dt                         in  varchar2  default null
  ,p_ext_crit_prfl_id               in  number    default null
  ,p_ext_file_id                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xdf_attribute_category         in  varchar2  default null
  ,p_xdf_attribute1                 in  varchar2  default null
  ,p_xdf_attribute2                 in  varchar2  default null
  ,p_xdf_attribute3                 in  varchar2  default null
  ,p_xdf_attribute4                 in  varchar2  default null
  ,p_xdf_attribute5                 in  varchar2  default null
  ,p_xdf_attribute6                 in  varchar2  default null
  ,p_xdf_attribute7                 in  varchar2  default null
  ,p_xdf_attribute8                 in  varchar2  default null
  ,p_xdf_attribute9                 in  varchar2  default null
  ,p_xdf_attribute10                in  varchar2  default null
  ,p_xdf_attribute11                in  varchar2  default null
  ,p_xdf_attribute12                in  varchar2  default null
  ,p_xdf_attribute13                in  varchar2  default null
  ,p_xdf_attribute14                in  varchar2  default null
  ,p_xdf_attribute15                in  varchar2  default null
  ,p_xdf_attribute16                in  varchar2  default null
  ,p_xdf_attribute17                in  varchar2  default null
  ,p_xdf_attribute18                in  varchar2  default null
  ,p_xdf_attribute19                in  varchar2  default null
  ,p_xdf_attribute20                in  varchar2  default null
  ,p_xdf_attribute21                in  varchar2  default null
  ,p_xdf_attribute22                in  varchar2  default null
  ,p_xdf_attribute23                in  varchar2  default null
  ,p_xdf_attribute24                in  varchar2  default null
  ,p_xdf_attribute25                in  varchar2  default null
  ,p_xdf_attribute26                in  varchar2  default null
  ,p_xdf_attribute27                in  varchar2  default null
  ,p_xdf_attribute28                in  varchar2  default null
  ,p_xdf_attribute29                in  varchar2  default null
  ,p_xdf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_drctry_name                    in  varchar2  default null
  ,p_kickoff_wrt_prc_flag           in  varchar2  default null
  ,p_upd_cm_sent_dt_flag            in  varchar2  default null
  ,p_spcl_hndl_flag                 in  varchar2  default null
  ,p_ext_global_flag                in  varchar2  default 'N'
  ,p_cm_display_flag                in  varchar2  default 'N'
  ,p_use_eff_dt_for_chgs_flag       in  varchar2  default null
  ,p_ext_post_prcs_rl                  in  number    default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_DEFN >------------------------|
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
--   p_ext_dfn_id                   Yes  number    PK of record
--   p_name                         No   varchar2
--   p_data_typ_cd                  No   varchar2
--   p_ext_typ_cd                   No   varchar2
--   p_output_name                  No   varchar2
--   p_output_type                  No   varchar2
--   p_apnd_rqst_id_flag            Yes  varchar2
--   p_prmy_sort_cd                 No   varchar2
--   p_scnd_sort_cd                 No   varchar2
--   p_strt_dt                      No   varchar2
--   p_end_dt                       No   varchar2
--   p_ext_crit_prfl_id             No   number
--   p_ext_file_id                  No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code            Yes  varchar2
--   p_xdf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_xdf_attribute1               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute2               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute3               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute4               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute5               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute6               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute7               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute8               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute9               No   varchar2  Descriptive Flexfield
--   p_xdf_attribute10              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute11              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute12              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute13              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute14              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute15              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute16              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute17              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute18              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute19              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute20              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute21              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute22              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute23              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute24              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute25              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute26              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute27              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute28              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute29              No   varchar2  Descriptive Flexfield
--   p_xdf_attribute30              No   varchar2  Descriptive Flexfield
--   p_drctry_name                  No   varchar2
--   p_kickoff_wrt_prc_flag         Yes  varchar2
--   p_upd_cm_sent_dt_flag          No   varchar2
--   p_spcl_hndl_flag               No   varchar2
--   p_ext_global_flag               No   varchar2
--   p_cm_display_flag               No   varchar2
--   p_use_eff_dt_for_chgs_flag     No   varchar2
--   p_ext_post_prcs_rl             No   number
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
procedure update_EXT_DEFN
  (
   p_validate                       in boolean    default false
  ,p_ext_dfn_id                     in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_xml_tag_name                   in  varchar2  default hr_api.g_varchar2
  ,p_xdo_template_id                in  number    default hr_api.g_number
  ,p_data_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_output_name                    in  varchar2  default hr_api.g_varchar2
  ,p_output_type                    in  varchar2  default hr_api.g_varchar2
  ,p_apnd_rqst_id_flag              in  varchar2  default hr_api.g_varchar2
  ,p_prmy_sort_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_scnd_sort_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_strt_dt                        in  varchar2  default hr_api.g_varchar2
  ,p_end_dt                         in  varchar2  default hr_api.g_varchar2
  ,p_ext_crit_prfl_id               in  number    default hr_api.g_number
  ,p_ext_file_id                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_drctry_name                    in  varchar2  default hr_api.g_varchar2
  ,p_kickoff_wrt_prc_flag           in  varchar2  default hr_api.g_varchar2
  ,p_upd_cm_sent_dt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_spcl_hndl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_ext_global_flag                in  varchar2  default hr_api.g_varchar2
  ,p_cm_display_flag                in  varchar2  default hr_api.g_varchar2
  ,p_use_eff_dt_for_chgs_flag       in  varchar2  default hr_api.g_varchar2
  ,p_ext_post_prcs_rl               in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_DEFN >------------------------|
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
--   p_ext_dfn_id                   Yes  number    PK of record
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
procedure delete_EXT_DEFN
  (
   p_validate                       in boolean        default false
  ,p_ext_dfn_id                     in  number
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
--   p_ext_dfn_id                 Yes  number   PK of record
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
    p_ext_dfn_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_EXT_DEFN_api;

 

/
