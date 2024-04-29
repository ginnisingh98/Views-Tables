--------------------------------------------------------
--  DDL for Package BEN_ELIG_CMBN_AGE_LOS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CMBN_AGE_LOS_BK3" AUTHID CURRENT_USER as
/* $Header: beecpapi.pkh 120.0 2005/05/28 01:51:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CMBN_AGE_LOS_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CMBN_AGE_LOS_b
  (
   p_elig_cmbn_age_los_prte_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CMBN_AGE_LOS_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CMBN_AGE_LOS_a
  (
   p_elig_cmbn_age_los_prte_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_CMBN_AGE_LOS_bk3;

 

/
