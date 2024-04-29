--------------------------------------------------------
--  DDL for Package BEN_ELIG_PER_ELC_CHC_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PER_ELC_CHC_BK3" AUTHID CURRENT_USER as
/* $Header: beepeapi.pkh 120.0 2005/05/28 02:36:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_PER_ELC_CHC_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_PER_ELC_CHC_b
  (
   p_elig_per_elctbl_chc_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_PER_ELC_CHC_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_PER_ELC_CHC_a
  (
   p_elig_per_elctbl_chc_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_PER_ELC_CHC_bk3;

 

/
