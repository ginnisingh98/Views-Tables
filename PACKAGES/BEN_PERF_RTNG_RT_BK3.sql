--------------------------------------------------------
--  DDL for Package BEN_PERF_RTNG_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERF_RTNG_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beprrapi.pkh 120.0 2005/05/28 11:12:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_perf_rtng_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_perf_rtng_rt_b
  (
   p_perf_rtng_rt_id   in  number
  ,p_object_version_number        in  number
  ,p_effective_date               in  date
  ,p_datetrack_mode               in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_perf_rtng_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_perf_rtng_rt_a
  (
   p_perf_rtng_rt_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
end ben_perf_rtng_rt_bk3;

 

/
