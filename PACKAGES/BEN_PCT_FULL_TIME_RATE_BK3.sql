--------------------------------------------------------
--  DDL for Package BEN_PCT_FULL_TIME_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCT_FULL_TIME_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bepfrapi.pkh 120.0 2005/05/28 10:43:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PCT_FULL_TIME_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PCT_FULL_TIME_RATE_b
  (
   p_pct_fl_tm_rt_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PCT_FULL_TIME_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PCT_FULL_TIME_RATE_a
  (
   p_pct_fl_tm_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PCT_FULL_TIME_RATE_bk3;

 

/