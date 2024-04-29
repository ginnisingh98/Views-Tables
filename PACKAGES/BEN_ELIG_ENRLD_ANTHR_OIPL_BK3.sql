--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_OIPL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_OIPL_BK3" AUTHID CURRENT_USER as
/* $Header: beeeiapi.pkh 120.0 2005/05/28 02:04:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_ENRLD_ANTHR_OIPL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_ENRLD_ANTHR_OIPL_b
  (
   p_elig_enrld_anthr_oipl_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_ENRLD_ANTHR_OIPL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_ENRLD_ANTHR_OIPL_a
  (
   p_elig_enrld_anthr_oipl_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_ENRLD_ANTHR_OIPL_bk3;

 

/
