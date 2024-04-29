--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVRD_O_PGM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVRD_O_PGM_BK3" AUTHID CURRENT_USER as
/* $Header: beedgapi.pkh 120.0 2005/05/28 01:58:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVRD_O_PGM_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVRD_O_PGM_b
  (
   p_elig_dpnt_cvrd_othr_pgm_id     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVRD_O_PGM_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVRD_O_PGM_a
  (
   p_elig_dpnt_cvrd_othr_pgm_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_DPNT_CVRD_O_PGM_bk3;

 

/
