--------------------------------------------------------
--  DDL for Package BEN_ELIG_DSBLTY_RSN_PRTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DSBLTY_RSN_PRTE_BK3" AUTHID CURRENT_USER as
/* $Header: beedrapi.pkh 120.0 2005/05/28 02:00:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_elig_dsblty_rsn_prte_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_dsblty_rsn_prte_b
  (
   p_elig_dsblty_rsn_prte_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_elig_dsblty_rsn_prte_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_dsblty_rsn_prte_a
  (
   p_elig_dsblty_rsn_prte_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_elig_dsblty_rsn_prte_bk3;

 

/