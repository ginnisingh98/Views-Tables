--------------------------------------------------------
--  DDL for Package BEN_CMBN_AGE_LOS_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_AGE_LOS_RT_BK3" AUTHID CURRENT_USER as
/* $Header: becmrapi.pkh 120.0 2005/05/28 01:06:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CMBN_AGE_LOS_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CMBN_AGE_LOS_RT_b
  (
   p_cmbn_age_los_rt_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CMBN_AGE_LOS_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CMBN_AGE_LOS_RT_a
  (
   p_cmbn_age_los_rt_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_CMBN_AGE_LOS_RT_bk3;

 

/
