--------------------------------------------------------
--  DDL for Package BEN_FULL_PRT_TIME_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FULL_PRT_TIME_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beftrapi.pkh 120.0 2005/05/28 03:05:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_FULL_PRT_TIME_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_FULL_PRT_TIME_RATE_b
  (
   p_fl_tm_pt_tm_rt_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_FULL_PRT_TIME_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_FULL_PRT_TIME_RATE_a
  (
   p_fl_tm_pt_tm_rt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_FULL_PRT_TIME_RATE_bk3;

 

/
