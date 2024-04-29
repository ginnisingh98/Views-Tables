--------------------------------------------------------
--  DDL for Package BEN_EMPLOYEE_STATUS_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMPLOYEE_STATUS_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beesrapi.pkh 120.0 2005/05/28 02:58:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EMPLOYEE_STATUS_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EMPLOYEE_STATUS_RT_b
  (
   p_ee_stat_rt_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EMPLOYEE_STATUS_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EMPLOYEE_STATUS_RT_a
  (
   p_ee_stat_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_EMPLOYEE_STATUS_RT_bk3;

 

/
