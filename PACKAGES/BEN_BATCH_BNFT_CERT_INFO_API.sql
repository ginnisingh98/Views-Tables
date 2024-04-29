--------------------------------------------------------
--  DDL for Package BEN_BATCH_BNFT_CERT_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_BNFT_CERT_INFO_API" AUTHID CURRENT_USER as
/* $Header: bebciapi.pkh 120.0.12010000.1 2008/07/29 10:53:31 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_bnft_cert_info >------------------------|
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
--   p_actn_typ_id                  No   number
--   p_typ_cd                       No   varchar2
--   p_enrt_ctfn_recd_dt            No   date
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_batch_benft_cert_id          Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_batch_bnft_cert_info
(
   p_validate                       in boolean    default false
  ,p_batch_benft_cert_id            out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_actn_typ_id                    in  number    default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_bnft_cert_info >------------------------|
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
--   p_batch_benft_cert_id          Yes  number    PK of record
--   p_benefit_action_id            Yes  number
--   p_person_id                    Yes  number
--   p_actn_typ_id                  No   number
--   p_typ_cd                       No   varchar2
--   p_enrt_ctfn_recd_dt            No   date
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
procedure update_batch_bnft_cert_info
  (
   p_validate                       in boolean    default false
  ,p_batch_benft_cert_id            in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_bnft_cert_info >------------------------|
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
--   p_batch_benft_cert_id          Yes  number    PK of record
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
procedure delete_batch_bnft_cert_info
  (
   p_validate                       in boolean        default false
  ,p_batch_benft_cert_id            in  number
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
--   p_batch_benft_cert_id                 Yes  number   PK of record
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
    p_batch_benft_cert_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_batch_bnft_cert_info_api;

/
