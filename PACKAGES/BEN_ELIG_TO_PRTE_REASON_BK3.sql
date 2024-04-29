--------------------------------------------------------
--  DDL for Package BEN_ELIG_TO_PRTE_REASON_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_TO_PRTE_REASON_BK3" AUTHID CURRENT_USER as
/* $Header: bepeoapi.pkh 120.0 2005/05/28 10:37:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ELIG_TO_PRTE_REASON_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_TO_PRTE_REASON_b
  (p_elig_to_prte_rsn_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ELIG_TO_PRTE_REASON_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_TO_PRTE_REASON_a
  (p_elig_to_prte_rsn_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_ELIG_TO_PRTE_REASON_bk3;

 

/
