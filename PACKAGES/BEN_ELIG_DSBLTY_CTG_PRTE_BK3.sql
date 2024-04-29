--------------------------------------------------------
--  DDL for Package BEN_ELIG_DSBLTY_CTG_PRTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DSBLTY_CTG_PRTE_BK3" AUTHID CURRENT_USER as
/* $Header: beectapi.pkh 120.0 2005/05/28 01:54:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_dsblty_ctg_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELIG_DSBLTY_CTG_PRTE_B
  (
   p_elig_dsblty_ctg_PRTE_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_dsblty_ctg_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELIG_DSBLTY_CTG_PRTE_A
  (
   p_elig_dsblty_ctg_PRTE_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode              in varchar2
  );
--
end BEN_ELIG_DSBLTY_CTG_PRTE_BK3;

 

/
