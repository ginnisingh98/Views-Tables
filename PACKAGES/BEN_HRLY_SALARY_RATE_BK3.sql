--------------------------------------------------------
--  DDL for Package BEN_HRLY_SALARY_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HRLY_SALARY_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: behsrapi.pkh 120.0 2005/05/28 03:11:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_HRLY_SALARY_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_HRLY_SALARY_RATE_b
  (
   p_hrly_slrd_rt_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_HRLY_SALARY_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_HRLY_SALARY_RATE_a
  (
   p_hrly_slrd_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_HRLY_SALARY_RATE_bk3;

 

/
