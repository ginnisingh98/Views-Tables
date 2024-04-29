--------------------------------------------------------
--  DDL for Package BEN_ENRLD_ANTHR_PGM_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRLD_ANTHR_PGM_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beepmapi.pkh 120.0 2005/05/28 02:40:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ENRLD_ANTHR_PGM_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ENRLD_ANTHR_PGM_RT_b
  (
   p_enrld_anthr_pgm_rt_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ENRLD_ANTHR_PGM_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ENRLD_ANTHR_PGM_RT_a
  (
   p_enrld_anthr_pgm_rt_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ENRLD_ANTHR_PGM_RT_bk3;

 

/
