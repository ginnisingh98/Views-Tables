--------------------------------------------------------
--  DDL for Package BEN_BATCH_RATE_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_RATE_INFO_API" AUTHID CURRENT_USER as
/* $Header: bebriapi.pkh 120.0 2005/05/28 00:51:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_rate_info >------------------------|
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
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_bnft_rt_typ_cd               No   varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_val                          No   number
--   p_tx_typ_cd                    No   varchar2
--   p_acty_typ_cd                  No   varchar2
--   p_mn_elcn_val                  No   number
--   p_mx_elcn_val                  No   number
--   p_incrmt_elcn_val              No   number
--   p_dflt_val                     No   number
--   p_rt_strt_dt                   No   date
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_cvg_thru_dt             No   date
--   p_actn_cd                      No   varchar2
--   p_close_actn_itm_dt            No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date           Yes  date      Session Date.
--   p_old_val                      No   number
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_rt_id                  Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_rate_info
  (p_validate                       in boolean    default false
  ,p_batch_rt_id                    out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_old_val                        in  number    default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_mn_elcn_val                    in  number    default null
  ,p_mx_elcn_val                    in  number    default null
  ,p_incrmt_elcn_val                in  number    default null
  ,p_dflt_val                       in  number    default null
  ,p_rt_strt_dt                     in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default null
  ,p_actn_cd                        in  varchar2  default null
  ,p_close_actn_itm_dt              in  date      default null
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_rate_info >------------------------|
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
--   p_batch_rt_id                  Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_bnft_rt_typ_cd               No   varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_val                          No   number
--   p_tx_typ_cd                    No   varchar2
--   p_acty_typ_cd                  No   varchar2
--   p_mn_elcn_val                  No   number
--   p_mx_elcn_val                  No   number
--   p_incrmt_elcn_val              No   number
--   p_dflt_val                     No   number
--   p_rt_strt_dt                   No   date
--   p_business_group_id            Yes  number    Business Group of Record
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_cvg_thru_dt             No   date
--   p_actn_cd                      No   varchar2
--   p_close_actn_itm_dt            No   date
--   p_effective_date          Yes  date       Session Date.
--   p_old_val                      No   number
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_batch_rate_info
  (p_validate                       in boolean    default false
  ,p_batch_rt_id                    in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_old_val                        in  number    default hr_api.g_number
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mn_elcn_val                    in  number    default hr_api.g_number
  ,p_mx_elcn_val                    in  number    default hr_api.g_number
  ,p_incrmt_elcn_val                in  number    default hr_api.g_number
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_actn_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_close_actn_itm_dt              in  date      default hr_api.g_date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_rate_info >------------------------|
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
--   p_batch_rt_id                  Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_batch_rate_info
  (p_validate                       in boolean        default false
  ,p_batch_rt_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date);
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
--   p_batch_rt_id                 Yes  number   PK of record
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
   (p_batch_rt_id                 in number
   ,p_object_version_number       in number);
--
end ben_batch_rate_info_api;

 

/
