--------------------------------------------------------
--  DDL for Package BEN_PRTT_ANTHR_PL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ANTHR_PL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bepapapi.pkh 120.0 2005/05/28 10:00:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ANTHR_PL_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ANTHR_PL_RT_b
  (
   p_prtt_anthr_pl_rt_id     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ANTHR_PL_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ANTHR_PL_RT_a
  (
   p_prtt_anthr_pl_rt_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRTT_ANTHR_PL_RT_bk3;

 

/
