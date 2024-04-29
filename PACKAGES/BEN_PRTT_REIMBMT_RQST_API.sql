--------------------------------------------------------
--  DDL for Package BEN_PRTT_REIMBMT_RQST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_REIMBMT_RQST_API" AUTHID CURRENT_USER as
/* $Header: beprcapi.pkh 120.1 2005/12/19 12:16:54 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_REIMBMT_RQST >------------------------|
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
--   p_incrd_from_dt                No   date
--   p_incrd_to_dt                  No   date
--   p_rqst_num                     No   number
--   p_rqst_amt                     No   number
--   p_rqst_amt_uom                 No   varchar2
--   p_rqst_btch_num                No   number
--   p_prtt_reimbmt_rqst_stat_cd    No   varchar2
--   p_reimbmt_ctfn_typ_prvdd_cd    No   varchar2
--   p_rcrrg_cd                     No   varchar2
--   p_submitter_person_id          No   number
--   p_recipient_person_id          No   number
--   p_provider_person_id           No   number
--   p_provider_ssn_person_id       No   number
--   p_pl_id                        Yes  number
--   p_gd_or_svc_typ_id             No   number
--   p_contact_relationship_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_prc_attribute1               No   varchar2  Descriptive Flexfield
--   p_prc_attribute2               No   varchar2  Descriptive Flexfield
--   p_prc_attribute3               No   varchar2  Descriptive Flexfield
--   p_prc_attribute4               No   varchar2  Descriptive Flexfield
--   p_prc_attribute5               No   varchar2  Descriptive Flexfield
--   p_prc_attribute6               No   varchar2  Descriptive Flexfield
--   p_prc_attribute7               No   varchar2  Descriptive Flexfield
--   p_prc_attribute8               No   varchar2  Descriptive Flexfield
--   p_prc_attribute9               No   varchar2  Descriptive Flexfield
--   p_prc_attribute10              No   varchar2  Descriptive Flexfield
--   p_prc_attribute11              No   varchar2  Descriptive Flexfield
--   p_prc_attribute12              No   varchar2  Descriptive Flexfield
--   p_prc_attribute13              No   varchar2  Descriptive Flexfield
--   p_prc_attribute14              No   varchar2  Descriptive Flexfield
--   p_prc_attribute15              No   varchar2  Descriptive Flexfield
--   p_prc_attribute16              No   varchar2  Descriptive Flexfield
--   p_prc_attribute17              No   varchar2  Descriptive Flexfield
--   p_prc_attribute18              No   varchar2  Descriptive Flexfield
--   p_prc_attribute19              No   varchar2  Descriptive Flexfield
--   p_prc_attribute20              No   varchar2  Descriptive Flexfield
--   p_prc_attribute21              No   varchar2  Descriptive Flexfield
--   p_prc_attribute22              No   varchar2  Descriptive Flexfield
--   p_prc_attribute23              No   varchar2  Descriptive Flexfield
--   p_prc_attribute24              No   varchar2  Descriptive Flexfield
--   p_prc_attribute25              No   varchar2  Descriptive Flexfield
--   p_prc_attribute26              No   varchar2  Descriptive Flexfield
--   p_prc_attribute27              No   varchar2  Descriptive Flexfield
--   p_prc_attribute28              No   varchar2  Descriptive Flexfield
--   p_prc_attribute29              No   varchar2  Descriptive Flexfield
--   p_prc_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--   P_STAT_RSN_CD                  No   varchar2
--   p_Pymt_stat_cd                 No   varchar2
--   p_pymt_stat_rsn_cd             No   varchar2
--   p_stat_ovrdn_flag              No   varchar2
--   p_stat_ovrdn_rsn_cd            No   varchar2
--   p_stat_prr_to_ovrd                  varchar2
--   p_pymt_stat_ovrdn_flag              varchar2
--   p_pymt_stat_ovrdn_rsn_cd            varchar2
--   p_pymt_stat_prr_to_ovrd             varchar2
--   p_Adjmt_flag                        varchar2
--   p_Submtd_dt                         Date,
--   p_Ttl_rqst_amt                      number ,
--   p_Aprvd_for_pymt_amt                number
--   p_exp_incurd_dt		    No   Date
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_prtt_reimbmt_rqst_id         Yes  number    PK of record
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
procedure create_PRTT_REIMBMT_RQST
(
   p_validate                       in boolean    default false
  ,p_prtt_reimbmt_rqst_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_incrd_from_dt                  in  date      default null
  ,p_incrd_to_dt                    in  date      default null
  ,p_rqst_num                       in out nocopy   number
  ,p_rqst_amt                       in  number    default null
  ,p_rqst_amt_uom                   in  varchar2  default null
  ,p_rqst_btch_num                  in  number    default null
  ,p_prtt_reimbmt_rqst_stat_cd      in out nocopy   varchar2
  ,p_reimbmt_ctfn_typ_prvdd_cd      in  varchar2  default null
  ,p_rcrrg_cd                       in  varchar2  default null
  ,p_submitter_person_id            in  number    default null
  ,p_recipient_person_id            in  number    default null
  ,p_provider_person_id             in  number    default null
  ,p_provider_ssn_person_id         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_gd_or_svc_typ_id               in  number    default null
  ,p_contact_relationship_id        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_popl_yr_perd_id_1              in  number    default null
  ,p_popl_yr_perd_id_2              in  number    default null
  ,p_amt_year1                      in  number    default null
  ,p_amt_year2                      in  number    default null
  ,p_prc_attribute_category         in  varchar2  default null
  ,p_prc_attribute1                 in  varchar2  default null
  ,p_prc_attribute2                 in  varchar2  default null
  ,p_prc_attribute3                 in  varchar2  default null
  ,p_prc_attribute4                 in  varchar2  default null
  ,p_prc_attribute5                 in  varchar2  default null
  ,p_prc_attribute6                 in  varchar2  default null
  ,p_prc_attribute7                 in  varchar2  default null
  ,p_prc_attribute8                 in  varchar2  default null
  ,p_prc_attribute9                 in  varchar2  default null
  ,p_prc_attribute10                in  varchar2  default null
  ,p_prc_attribute11                in  varchar2  default null
  ,p_prc_attribute12                in  varchar2  default null
  ,p_prc_attribute13                in  varchar2  default null
  ,p_prc_attribute14                in  varchar2  default null
  ,p_prc_attribute15                in  varchar2  default null
  ,p_prc_attribute16                in  varchar2  default null
  ,p_prc_attribute17                in  varchar2  default null
  ,p_prc_attribute18                in  varchar2  default null
  ,p_prc_attribute19                in  varchar2  default null
  ,p_prc_attribute20                in  varchar2  default null
  ,p_prc_attribute21                in  varchar2  default null
  ,p_prc_attribute22                in  varchar2  default null
  ,p_prc_attribute23                in  varchar2  default null
  ,p_prc_attribute24                in  varchar2  default null
  ,p_prc_attribute25                in  varchar2  default null
  ,p_prc_attribute26                in  varchar2  default null
  ,p_prc_attribute27                in  varchar2  default null
  ,p_prc_attribute28                in  varchar2  default null
  ,p_prc_attribute29                in  varchar2  default null
  ,p_prc_attribute30                in  varchar2  default null
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_comment_id                     in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_stat_rsn_cd                    in  out nocopy varchar2
  ,p_pymt_stat_cd                   in  out nocopy varchar2
  ,p_pymt_stat_rsn_cd               in  out nocopy varchar2
  ,p_stat_ovrdn_flag                in  varchar2  default null
  ,p_stat_ovrdn_rsn_cd              in  varchar2  default null
  ,p_stat_prr_to_ovrd               in  varchar2  default null
  ,p_pymt_stat_ovrdn_flag           in  varchar2  default null
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default null
  ,p_pymt_stat_prr_to_ovrd          in  varchar2  default null
  ,p_Adjmt_flag                     in  varchar2  default null
  ,p_Submtd_dt                      in  date      default null
  ,p_Ttl_rqst_amt                   in  number    default null
  ,p_Aprvd_for_pymt_amt             in out nocopy  number
  ,p_exp_incurd_dt		    in  date      default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_REIMBMT_RQST >------------------------|
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
--   p_prtt_reimbmt_rqst_id         Yes  number    PK of record
--   p_incrd_from_dt                No   date
--   p_incrd_to_dt                  No   date
--   p_rqst_num                     No   number
--   p_rqst_amt                     No   number
--   p_rqst_amt_uom                 No   varchar2
--   p_rqst_btch_num                No   number
--   p_prtt_reimbmt_rqst_stat_cd    No   varchar2
--   p_reimbmt_ctfn_typ_prvdd_cd    No   varchar2
--   p_rcrrg_cd                     No   varchar2
--   p_submitter_person_id          No   number
--   p_recipient_person_id          No   number
--   p_provider_person_id           No   number
--   p_provider_ssn_person_id       No   number
--   p_pl_id                        Yes  number
--   p_gd_or_svc_typ_id             No   number
--   p_contact_relationship_id      No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_prc_attribute_category       No   varchar2  Descriptive Flexfield
--   p_prc_attribute1               No   varchar2  Descriptive Flexfield
--   p_prc_attribute2               No   varchar2  Descriptive Flexfield
--   p_prc_attribute3               No   varchar2  Descriptive Flexfield
--   p_prc_attribute4               No   varchar2  Descriptive Flexfield
--   p_prc_attribute5               No   varchar2  Descriptive Flexfield
--   p_prc_attribute6               No   varchar2  Descriptive Flexfield
--   p_prc_attribute7               No   varchar2  Descriptive Flexfield
--   p_prc_attribute8               No   varchar2  Descriptive Flexfield
--   p_prc_attribute9               No   varchar2  Descriptive Flexfield
--   p_prc_attribute10              No   varchar2  Descriptive Flexfield
--   p_prc_attribute11              No   varchar2  Descriptive Flexfield
--   p_prc_attribute12              No   varchar2  Descriptive Flexfield
--   p_prc_attribute13              No   varchar2  Descriptive Flexfield
--   p_prc_attribute14              No   varchar2  Descriptive Flexfield
--   p_prc_attribute15              No   varchar2  Descriptive Flexfield
--   p_prc_attribute16              No   varchar2  Descriptive Flexfield
--   p_prc_attribute17              No   varchar2  Descriptive Flexfield
--   p_prc_attribute18              No   varchar2  Descriptive Flexfield
--   p_prc_attribute19              No   varchar2  Descriptive Flexfield
--   p_prc_attribute20              No   varchar2  Descriptive Flexfield
--   p_prc_attribute21              No   varchar2  Descriptive Flexfield
--   p_prc_attribute22              No   varchar2  Descriptive Flexfield
--   p_prc_attribute23              No   varchar2  Descriptive Flexfield
--   p_prc_attribute24              No   varchar2  Descriptive Flexfield
--   p_prc_attribute25              No   varchar2  Descriptive Flexfield
--   p_prc_attribute26              No   varchar2  Descriptive Flexfield
--   p_prc_attribute27              No   varchar2  Descriptive Flexfield
--   p_prc_attribute28              No   varchar2  Descriptive Flexfield
--   p_prc_attribute29              No   varchar2  Descriptive Flexfield
--   p_prc_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_exp_incurd_dt                No   date
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
procedure update_PRTT_REIMBMT_RQST
  (
   p_validate                       in boolean    default false
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_incrd_from_dt                  in  date      default hr_api.g_date
  ,p_incrd_to_dt                    in  date      default hr_api.g_date
  ,p_rqst_num                       in  number    default hr_api.g_number
  ,p_rqst_amt                       in  number    default hr_api.g_number
  ,p_rqst_amt_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_rqst_btch_num                  in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_stat_cd      in  out nocopy  varchar2
  ,p_reimbmt_ctfn_typ_prvdd_cd      in  varchar2  default hr_api.g_varchar2
  ,p_rcrrg_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_submitter_person_id            in  number    default hr_api.g_number
  ,p_recipient_person_id            in  number    default hr_api.g_number
  ,p_provider_person_id             in  number    default hr_api.g_number
  ,p_provider_ssn_person_id         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_gd_or_svc_typ_id               in  number    default hr_api.g_number
  ,p_contact_relationship_id        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_popl_yr_perd_id_1              in  number    default hr_api.g_number
  ,p_popl_yr_perd_id_2              in  number    default hr_api.g_number
  ,p_amt_year1                      in  number    default hr_api.g_number
  ,p_amt_year2                      in  number    default hr_api.g_number
  ,p_prc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_comment_id                     in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_stat_rsn_cd                    in  out nocopy varchar2
  ,p_Pymt_stat_cd                   in  out nocopy varchar2
  ,p_pymt_stat_rsn_cd               in  out nocopy varchar2
  ,p_stat_ovrdn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_stat_ovrdn_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_stat_prr_to_ovrd               in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_ovrdn_flag           in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_prr_to_ovrd          in  varchar2  default hr_api.g_varchar2
  ,p_Adjmt_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_Submtd_dt                      in  date      default hr_api.g_date
  ,p_Ttl_rqst_amt                   in  number    default hr_api.g_number
  ,p_Aprvd_for_pymt_amt             in  out nocopy number
  ,p_exp_incurd_dt		    in  date      default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_REIMBMT_RQST >------------------------|
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
--   p_prtt_reimbmt_rqst_id         Yes  number    PK of record
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
procedure delete_PRTT_REIMBMT_RQST
  (
   p_validate                       in boolean        default false
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_submitter_person_id            in number
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
--   p_prtt_reimbmt_rqst_id                 Yes  number   PK of record
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
    p_prtt_reimbmt_rqst_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_PRTT_REIMBMT_RQST_api;

 

/
