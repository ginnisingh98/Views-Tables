--------------------------------------------------------
--  DDL for Package BEN_WORK_LOC_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WORK_LOC_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bewlrapi.pkh 120.0 2005/05/28 12:17:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORK_LOC_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORK_LOC_RATE_b
  (
   p_wk_loc_rt_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WORK_LOC_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORK_LOC_RATE_a
  (
   p_wk_loc_rt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_WORK_LOC_RATE_bk3;

 

/
