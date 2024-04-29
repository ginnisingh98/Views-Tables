--------------------------------------------------------
--  DDL for Package BEN_HRS_WKD_IN_PERIOD_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRS_WKD_IN_PERIOD_RT_BK3" AUTHID CURRENT_USER as
/* $Header: behwrapi.pkh 120.0 2005/05/28 03:12:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_HRS_WKD_IN_PERIOD_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_HRS_WKD_IN_PERIOD_RT_b
  (
   p_hrs_wkd_in_perd_rt_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_HRS_WKD_IN_PERIOD_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_HRS_WKD_IN_PERIOD_RT_a
  (
   p_hrs_wkd_in_perd_rt_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_HRS_WKD_IN_PERIOD_RT_bk3;

 

/
