--------------------------------------------------------
--  DDL for Package BEN_PYMT_SCHED_PY_FREQ_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYMT_SCHED_PY_FREQ_BK3" AUTHID CURRENT_USER as
/* $Header: bepsqapi.pkh 120.0 2005/05/28 11:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pymt_sched_py_freq_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_sched_py_freq_b
  (
   p_pymt_sched_py_freq_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pymt_sched_py_freq_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pymt_sched_py_freq_a
  (
   p_pymt_sched_py_freq_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pymt_sched_py_freq_bk3;

 

/
