--------------------------------------------------------
--  DDL for Package BEN_BATCH_ELCTBL_CHC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ELCTBL_CHC_API" AUTHID CURRENT_USER as
/* $Header: bebecapi.pkh 120.0 2005/05/28 00:37:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_elctbl_chc >-----------------------|
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
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_enrt_perd_end_dt             No   date
--   p_erlst_deenrt_dt              No   date
--   p_dflt_enrt_dt                 No   date
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_comp_lvl_cd                  No   varchar2
--   p_mndtry_flag                  Yes  varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_elctbl_id              Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_elctbl_chc
  (p_validate                       in boolean    default false
  ,p_batch_elctbl_id                out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_elctbl_chc >-----------------------|
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
--   p_batch_elctbl_id              Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_enrt_cvg_strt_dt             No   date
--   p_enrt_perd_strt_dt            No   date
--   p_enrt_perd_end_dt             No   date
--   p_erlst_deenrt_dt              No   date
--   p_dflt_enrt_dt                 No   date
--   p_enrt_typ_cycl_cd             No   varchar2
--   p_comp_lvl_cd                  No   varchar2
--   p_mndtry_flag                  Yes  varchar2
--   p_dflt_flag                    Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_effective_date          Yes  date       Session Date.
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
procedure update_batch_elctbl_chc
  (p_validate                       in boolean    default false
  ,p_batch_elctbl_id                in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_elctbl_chc >-----------------------|
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
--   p_batch_elctbl_id              Yes  number    PK of record
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
procedure delete_batch_elctbl_chc
  (p_validate                       in boolean        default false
  ,p_batch_elctbl_id                in  number
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
--   p_batch_elctbl_id                 Yes  number   PK of record
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
   (p_batch_elctbl_id              in number
   ,p_object_version_number        in number);
--
end ben_batch_elctbl_chc_api;

 

/
