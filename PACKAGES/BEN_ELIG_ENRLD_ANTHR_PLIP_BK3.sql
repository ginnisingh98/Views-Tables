--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_PLIP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_PLIP_BK3" AUTHID CURRENT_USER as
/* $Header: beeaiapi.pkh 120.0 2005/05/28 01:42:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_ENRLD_ANTHR_PLIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_ENRLD_ANTHR_PLIP_b
  (
   p_elig_enrld_anthr_plip_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_ENRLD_ANTHR_PLIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_ENRLD_ANTHR_PLIP_a
  (
   p_elig_enrld_anthr_plip_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_ENRLD_ANTHR_PLIP_bk3;

 

/
