--------------------------------------------------------
--  DDL for Package BEN_APLD_DPNT_CVG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APLD_DPNT_CVG_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: beadeapi.pkh 120.0 2005/05/28 00:21:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Apld_Dpnt_Cvg_Prfl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Apld_Dpnt_Cvg_Prfl_b
  (
   p_apld_dpnt_cvg_elig_prfl_id     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Apld_Dpnt_Cvg_Prfl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Apld_Dpnt_Cvg_Prfl_a
  (
   p_apld_dpnt_cvg_elig_prfl_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Apld_Dpnt_Cvg_Prfl_bk3;

 

/
