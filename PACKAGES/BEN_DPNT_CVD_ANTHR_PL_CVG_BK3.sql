--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVD_ANTHR_PL_CVG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVD_ANTHR_PL_CVG_BK3" AUTHID CURRENT_USER as
/* $Header: bedpcapi.pkh 120.0 2005/05/28 01:38:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVD_ANTHR_PL_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVD_ANTHR_PL_CVG_b
  (
   p_dpnt_cvrd_anthr_pl_cvg_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVD_ANTHR_PL_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVD_ANTHR_PL_CVG_a
  (
   p_dpnt_cvrd_anthr_pl_cvg_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DPNT_CVD_ANTHR_PL_CVG_bk3;

 

/
