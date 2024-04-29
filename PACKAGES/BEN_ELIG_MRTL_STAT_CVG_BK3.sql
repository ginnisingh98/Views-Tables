--------------------------------------------------------
--  DDL for Package BEN_ELIG_MRTL_STAT_CVG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_MRTL_STAT_CVG_BK3" AUTHID CURRENT_USER as
/* $Header: beemsapi.pkh 120.0 2005/05/28 02:26:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Elig_Mrtl_Stat_Cvg_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Elig_Mrtl_Stat_Cvg_b
  (
   p_elig_mrtl_stat_cvg_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Elig_Mrtl_Stat_Cvg_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Elig_Mrtl_Stat_Cvg_a
  (
   p_elig_mrtl_stat_cvg_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Elig_Mrtl_Stat_Cvg_bk3;

 

/
