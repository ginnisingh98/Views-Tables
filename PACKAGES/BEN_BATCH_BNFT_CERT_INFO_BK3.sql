--------------------------------------------------------
--  DDL for Package BEN_BATCH_BNFT_CERT_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_BNFT_CERT_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: bebciapi.pkh 120.0.12010000.1 2008/07/29 10:53:31 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_bnft_cert_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_bnft_cert_info_b
  (
   p_batch_benft_cert_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_bnft_cert_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_bnft_cert_info_a
  (
   p_batch_benft_cert_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_batch_bnft_cert_info_bk3;

/
