--------------------------------------------------------
--  DDL for Package BEN_JOB_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_JOB_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bejrtapi.pkh 120.0 2005/05/28 03:13:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_JOB_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_JOB_RT_b
  (
   p_job_rt_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_JOB_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_JOB_RT_a
  (
   p_job_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
end ben_JOB_RT_bk3;

 

/
