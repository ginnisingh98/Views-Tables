--------------------------------------------------------
--  DDL for Package BEN_ACTY_RT_PYMT_SCHED_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_RT_PYMT_SCHED_BK3" AUTHID CURRENT_USER as
/* $Header: beapfapi.pkh 120.0 2005/05/28 00:25:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_rt_pymt_sched_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_rt_pymt_sched_b
  (
   p_acty_rt_pymt_sched_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_rt_pymt_sched_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_rt_pymt_sched_a
  (
   p_acty_rt_pymt_sched_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_acty_rt_pymt_sched_bk3;

 

/
