--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVRD_OTHR_PL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVRD_OTHR_PL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bedclapi.pkh 120.0 2005/05/28 01:32:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVRD_OTHR_PL_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVRD_OTHR_PL_RT_b
  (
   p_dpnt_cvrd_othr_pl_rt_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVRD_OTHR_PL_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVRD_OTHR_PL_RT_a
  (
   p_dpnt_cvrd_othr_pl_rt_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DPNT_CVRD_OTHR_PL_RT_bk3;

 

/
