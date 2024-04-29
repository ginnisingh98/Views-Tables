--------------------------------------------------------
--  DDL for Package BEN_ELIG_STDNT_STAT_CVG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_STDNT_STAT_CVG_BK3" AUTHID CURRENT_USER as
/* $Header: beescapi.pkh 120.0 2005/05/28 02:54:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_STDNT_STAT_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_STDNT_STAT_CVG_b
  (
   p_elig_stdnt_stat_cvg_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_STDNT_STAT_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_STDNT_STAT_CVG_a
  (
   p_elig_stdnt_stat_cvg_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_STDNT_STAT_CVG_bk3;

 

/
