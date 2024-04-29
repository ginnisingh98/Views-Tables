--------------------------------------------------------
--  DDL for Package BEN_PRTT_RT_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_RT_VAL_API" AUTHID CURRENT_USER as
/* $Header: beprvapi.pkh 120.0.12000000.1 2007/01/19 22:14:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_prtt_rt_val >------------------------|
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
--   p_rt_strt_dt                   Yes  date
--   p_rt_end_dt                    Yes  date
--   p_rt_typ_cd                    No   varchar2
--   p_tx_typ_cd                    No   varchar2
--   p_acty_typ_cd                  No   varchar2
--   p_ordr_num                     Yes  number
--   p_mlt_cd                       No   varchar2
--   p_acty_ref_perd_cd             No   varchar2
--   p_rt_val                       No   number
--   p_ann_rt_val                   No   number
--   p_cmcd_rt_val                  No   number
--   p_cmcd_ref_perd_cd             No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_dsply_on_enrt_flag           Yes  varchar2
--   p_rt_ovridn_flag               Yes  varchar2
--   p_rt_ovridn_thru_dt            No   date
--   p_elctns_made_dt               No   date
--   p_prtt_rt_val_stat_cd          No   varchar2
--   p_prtt_enrt_rslt_id            Yes  number
--   p_cvg_amt_calc_mthd_id         No   number
--   p_actl_prem_id                 No   number
--   p_comp_lvl_fctr_id             No   number
--   p_element_entry_value_id       No   number
--   p_per_in_ler_id                No   number
--   p_ended_per_in_ler_id          No   number
--   p_acty_base_rt_id              No   number
--   p_prtt_reimbmt_rqst_id         No   number
--   p_prtt_rmt_aprvd_fr_pymt_id    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prv_attribute_category       No   varchar2  Descriptive Flexfield
--   p_prv_attribute1               No   varchar2  Descriptive Flexfield
--   p_prv_attribute2               No   varchar2  Descriptive Flexfield
--   p_prv_attribute3               No   varchar2  Descriptive Flexfield
--   p_prv_attribute4               No   varchar2  Descriptive Flexfield
--   p_prv_attribute5               No   varchar2  Descriptive Flexfield
--   p_prv_attribute6               No   varchar2  Descriptive Flexfield
--   p_prv_attribute7               No   varchar2  Descriptive Flexfield
--   p_prv_attribute8               No   varchar2  Descriptive Flexfield
--   p_prv_attribute9               No   varchar2  Descriptive Flexfield
--   p_prv_attribute10              No   varchar2  Descriptive Flexfield
--   p_prv_attribute11              No   varchar2  Descriptive Flexfield
--   p_prv_attribute12              No   varchar2  Descriptive Flexfield
--   p_prv_attribute13              No   varchar2  Descriptive Flexfield
--   p_prv_attribute14              No   varchar2  Descriptive Flexfield
--   p_prv_attribute15              No   varchar2  Descriptive Flexfield
--   p_prv_attribute16              No   varchar2  Descriptive Flexfield
--   p_prv_attribute17              No   varchar2  Descriptive Flexfield
--   p_prv_attribute18              No   varchar2  Descriptive Flexfield
--   p_prv_attribute19              No   varchar2  Descriptive Flexfield
--   p_prv_attribute20              No   varchar2  Descriptive Flexfield
--   p_prv_attribute21              No   varchar2  Descriptive Flexfield
--   p_prv_attribute22              No   varchar2  Descriptive Flexfield
--   p_prv_attribute23              No   varchar2  Descriptive Flexfield
--   p_prv_attribute24              No   varchar2  Descriptive Flexfield
--   p_prv_attribute25              No   varchar2  Descriptive Flexfield
--   p_prv_attribute26              No   varchar2  Descriptive Flexfield
--   p_prv_attribute27              No   varchar2  Descriptive Flexfield
--   p_prv_attribute28              No   varchar2  Descriptive Flexfield
--   p_prv_attribute29              No   varchar2  Descriptive Flexfield
--   p_prv_attribute30              No   varchar2  Descriptive Flexfield
--   p_pk_id_table_name             No   varchar2
--   p_pk_id                        No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_rt_val_id               Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_prtt_rt_val
(
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_id                 out nocopy number
  ,p_enrt_rt_id			    in number default null
  ,p_person_id                      in  number
  ,p_input_value_id                 in  number
  ,p_element_type_id                in  number
  ,p_rt_strt_dt                     in  date      default null
  ,p_rt_end_dt                      in  date      default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_ordr_num			    in  number    default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_mlt_cd                         in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_rt_val                         in  number    default null
  ,p_ann_rt_val                     in  number    default null
  ,p_cmcd_rt_val                    in  number    default null
  ,p_cmcd_ref_perd_cd               in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_dsply_on_enrt_flag             in  varchar2  default 'N'
  ,p_rt_ovridn_flag                 in  varchar2  default 'N'
  ,p_rt_ovridn_thru_dt              in  date      default null
  ,p_elctns_made_dt                 in  date      default null
  ,p_prtt_rt_val_stat_cd            in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_element_entry_value_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_ended_per_in_ler_id            in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_prtt_reimbmt_rqst_id           in  number    default null
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default null
  ,p_pp_in_yr_used_num              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_prv_attribute_category         in  varchar2  default null
  ,p_prv_attribute1                 in  varchar2  default null
  ,p_prv_attribute2                 in  varchar2  default null
  ,p_prv_attribute3                 in  varchar2  default null
  ,p_prv_attribute4                 in  varchar2  default null
  ,p_prv_attribute5                 in  varchar2  default null
  ,p_prv_attribute6                 in  varchar2  default null
  ,p_prv_attribute7                 in  varchar2  default null
  ,p_prv_attribute8                 in  varchar2  default null
  ,p_prv_attribute9                 in  varchar2  default null
  ,p_prv_attribute10                in  varchar2  default null
  ,p_prv_attribute11                in  varchar2  default null
  ,p_prv_attribute12                in  varchar2  default null
  ,p_prv_attribute13                in  varchar2  default null
  ,p_prv_attribute14                in  varchar2  default null
  ,p_prv_attribute15                in  varchar2  default null
  ,p_prv_attribute16                in  varchar2  default null
  ,p_prv_attribute17                in  varchar2  default null
  ,p_prv_attribute18                in  varchar2  default null
  ,p_prv_attribute19                in  varchar2  default null
  ,p_prv_attribute20                in  varchar2  default null
  ,p_prv_attribute21                in  varchar2  default null
  ,p_prv_attribute22                in  varchar2  default null
  ,p_prv_attribute23                in  varchar2  default null
  ,p_prv_attribute24                in  varchar2  default null
  ,p_prv_attribute25                in  varchar2  default null
  ,p_prv_attribute26                in  varchar2  default null
  ,p_prv_attribute27                in  varchar2  default null
  ,p_prv_attribute28                in  varchar2  default null
  ,p_prv_attribute29                in  varchar2  default null
  ,p_prv_attribute30                in  varchar2  default null
  ,p_pk_id_table_name               in  varchar2  default null
  ,p_pk_id                          in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_prtt_rt_val >------------------------|
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
--   p_prtt_rt_val_id               Yes  number    PK of record
--   p_rt_strt_dt                   Yes  date
--   p_rt_end_dt                    Yes  date
--   p_rt_typ_cd                    No   varchar2
--   p_tx_typ_cd                    No   varchar2
--   p_ordr_num                     Yes  number
--   p_acty_typ_cd                  No   varchar2
--   p_mlt_cd                       No   varchar2
--   p_acty_ref_perd_cd             No   varchar2
--   p_rt_val                       No   number
--   p_ann_rt_val                   No   number
--   p_cmcd_rt_val                  No   number
--   p_cmcd_ref_perd_cd             No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_dsply_on_enrt_flag           Yes  varchar2
--   p_rt_ovridn_flag               Yes  varchar2
--   p_rt_ovridn_thru_dt            No   date
--   p_elctns_made_dt               No   date
--   p_prtt_rt_val_stat_cd          No   varchar2
--   p_prtt_enrt_rslt_id            Yes  number
--   p_cvg_amt_calc_mthd_id         No   number
--   p_actl_prem_id                 No   number
--   p_comp_lvl_fctr_id             No   number
--   p_element_entry_value_id       No   number
--   p_per_in_ler_id                No   number
--   p_ended_per_in_ler_id          No   number
--   p_acty_base_rt_id              No   number
--   p_prtt_reimbmt_rqst_id         No   number
--   p_prtt_rmt_aprvd_fr_pymt_id    No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prv_attribute_category       No   varchar2  Descriptive Flexfield
--   p_prv_attribute1               No   varchar2  Descriptive Flexfield
--   p_prv_attribute2               No   varchar2  Descriptive Flexfield
--   p_prv_attribute3               No   varchar2  Descriptive Flexfield
--   p_prv_attribute4               No   varchar2  Descriptive Flexfield
--   p_prv_attribute5               No   varchar2  Descriptive Flexfield
--   p_prv_attribute6               No   varchar2  Descriptive Flexfield
--   p_prv_attribute7               No   varchar2  Descriptive Flexfield
--   p_prv_attribute8               No   varchar2  Descriptive Flexfield
--   p_prv_attribute9               No   varchar2  Descriptive Flexfield
--   p_prv_attribute10              No   varchar2  Descriptive Flexfield
--   p_prv_attribute11              No   varchar2  Descriptive Flexfield
--   p_prv_attribute12              No   varchar2  Descriptive Flexfield
--   p_prv_attribute13              No   varchar2  Descriptive Flexfield
--   p_prv_attribute14              No   varchar2  Descriptive Flexfield
--   p_prv_attribute15              No   varchar2  Descriptive Flexfield
--   p_prv_attribute16              No   varchar2  Descriptive Flexfield
--   p_prv_attribute17              No   varchar2  Descriptive Flexfield
--   p_prv_attribute18              No   varchar2  Descriptive Flexfield
--   p_prv_attribute19              No   varchar2  Descriptive Flexfield
--   p_prv_attribute20              No   varchar2  Descriptive Flexfield
--   p_prv_attribute21              No   varchar2  Descriptive Flexfield
--   p_prv_attribute22              No   varchar2  Descriptive Flexfield
--   p_prv_attribute23              No   varchar2  Descriptive Flexfield
--   p_prv_attribute24              No   varchar2  Descriptive Flexfield
--   p_prv_attribute25              No   varchar2  Descriptive Flexfield
--   p_prv_attribute26              No   varchar2  Descriptive Flexfield
--   p_prv_attribute27              No   varchar2  Descriptive Flexfield
--   p_prv_attribute28              No   varchar2  Descriptive Flexfield
--   p_prv_attribute29              No   varchar2  Descriptive Flexfield
--   p_prv_attribute30              No   varchar2  Descriptive Flexfield
--   p_pk_id_table_name             No   varchar2
--   p_pk_id                        No   number
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
procedure update_prtt_rt_val
  (
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_id                 in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_enrt_rt_id                     in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_rt_end_dt                      in  date      default hr_api.g_date
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num			    in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rt_val                         in  number    default hr_api.g_number
  ,p_ann_rt_val                     in  number    default hr_api.g_number
  ,p_cmcd_rt_val                    in  number    default hr_api.g_number
  ,p_cmcd_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_thru_dt              in  date      default hr_api.g_date
  ,p_elctns_made_dt                 in  date      default hr_api.g_date
  ,p_prtt_rt_val_stat_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_element_entry_value_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ended_per_in_ler_id            in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default hr_api.g_number
  ,p_pp_in_yr_used_num              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_pk_id_table_name               in  varchar2  default hr_api.g_varchar2
  ,p_pk_id                          in  number    default hr_api.g_number
  ,p_no_end_element                 in  boolean   default false
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_prtt_rt_val >------------------------|
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
--   p_prtt_rt_val_id               Yes  number    PK of record
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
procedure delete_prtt_rt_val
  (
   p_validate                       in boolean        default false
  ,p_prtt_rt_val_id                 in  number
  ,p_enrt_rt_id			      in  number default null
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
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
--   p_prtt_rt_val_id                 Yes  number   PK of record
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
    p_prtt_rt_val_id                 in number
   ,p_object_version_number        in number
  );
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_overlapping_dates  >---------------------|
-- ---------------------------------------------------------------------------
--
procedure chk_overlapping_dates
  (p_acty_base_rt_id                in  number
  ,p_prtt_rt_val_id                 in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_new_rt_strt_dt                 in  date
  ,p_new_rt_end_dt                  in  date
  );
--
-- ---------------------------------------------------------------------------
-- |------------------------< get_non_recurring_end_dt >---------------------|
-- ---------------------------------------------------------------------------
--
procedure get_non_recurring_end_dt
(  p_rt_strt_dt              date
  ,p_acty_base_rt_id         number
  ,p_business_group_id       number
  ,p_rt_end_dt               in out nocopy date
  ,p_recurring_rt            out nocopy boolean
  ,p_effective_date          date
 ) ;
--
function result_is_suspended
(  p_prtt_enrt_rslt_id              number
  ,p_person_id                      number
  ,p_business_group_id              number
  ,p_effective_date                 date
 ) return varchar2 ;
--
end ben_prtt_rt_val_api;

 

/
