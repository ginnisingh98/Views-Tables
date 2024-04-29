--------------------------------------------------------
--  DDL for Package BEN_DEDUCT_SCHED_PAY_FREQ_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DEDUCT_SCHED_PAY_FREQ_BK3" AUTHID CURRENT_USER as
/* $Header: bedsqapi.pkh 120.0 2005/05/28 01:40:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DEDUCT_SCHED_PAY_FREQ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DEDUCT_SCHED_PAY_FREQ_b
  (
   p_ded_sched_py_freq_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DEDUCT_SCHED_PAY_FREQ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DEDUCT_SCHED_PAY_FREQ_a
  (
   p_ded_sched_py_freq_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_DEDUCT_SCHED_PAY_FREQ_bk3;

 

/
