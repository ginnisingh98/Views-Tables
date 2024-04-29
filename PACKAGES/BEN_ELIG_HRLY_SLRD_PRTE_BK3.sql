--------------------------------------------------------
--  DDL for Package BEN_ELIG_HRLY_SLRD_PRTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_HRLY_SLRD_PRTE_BK3" AUTHID CURRENT_USER as
/* $Header: beehsapi.pkh 120.0 2005/05/28 02:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_HRLY_SLRD_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_HRLY_SLRD_PRTE_b
  (
   p_elig_hrly_slrd_prte_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_HRLY_SLRD_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_HRLY_SLRD_PRTE_a
  (
   p_elig_hrly_slrd_prte_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_HRLY_SLRD_PRTE_bk3;

 

/
