--------------------------------------------------------
--  DDL for Package BEN_ACTY_RT_DEDUCT_SCHED_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_RT_DEDUCT_SCHED_BK3" AUTHID CURRENT_USER as
/* $Header: beadsapi.pkh 120.0 2005/05/28 00:22:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ACTY_RT_DEDUCT_SCHED_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTY_RT_DEDUCT_SCHED_b
  (
   p_acty_rt_ded_sched_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ACTY_RT_DEDUCT_SCHED_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ACTY_RT_DEDUCT_SCHED_a
  (
   p_acty_rt_ded_sched_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ACTY_RT_DEDUCT_SCHED_bk3;

 

/
