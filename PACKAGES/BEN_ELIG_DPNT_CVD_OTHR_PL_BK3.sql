--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVD_OTHR_PL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVD_OTHR_PL_BK3" AUTHID CURRENT_USER as
/* $Header: beedpapi.pkh 120.0 2005/05/28 02:00:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVD_OTHR_PL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVD_OTHR_PL_b
  (
   p_elig_dpnt_cvrd_othr_pl_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVD_OTHR_PL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVD_OTHR_PL_a
  (
   p_elig_dpnt_cvrd_othr_pl_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_DPNT_CVD_OTHR_PL_bk3;

 

/
