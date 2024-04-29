--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVG_ELIG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVG_ELIG_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: bedceapi.pkh 120.0.12010000.2 2010/04/07 06:40:30 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVG_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVG_ELIG_PRFL_b
  (
   p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVG_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVG_ELIG_PRFL_a
  (
   p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             in  date
  ,p_effective_start_date           in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DPNT_CVG_ELIG_PRFL_bk3;

/
