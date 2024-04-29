--------------------------------------------------------
--  DDL for Package BEN_BATCH_BNFT_CERT_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_BNFT_CERT_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: bebciapi.pkh 120.0.12010000.1 2008/07/29 10:53:31 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_bnft_cert_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_bnft_cert_info_b
  (
   p_batch_benft_cert_id            in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_actn_typ_id                    in  number
  ,p_typ_cd                         in  varchar2
  ,p_enrt_ctfn_recd_dt              in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_batch_bnft_cert_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_bnft_cert_info_a
  (
   p_batch_benft_cert_id            in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_actn_typ_id                    in  number
  ,p_typ_cd                         in  varchar2
  ,p_enrt_ctfn_recd_dt              in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_batch_bnft_cert_info_bk2;

/
