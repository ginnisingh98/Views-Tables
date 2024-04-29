--------------------------------------------------------
--  DDL for Package BEN_QUA_IN_GR_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QUA_IN_GR_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beqigapi.pkh 120.0 2005/05/28 11:31:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_QUA_IN_GR_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_QUA_IN_GR_RT_b
  (
   p_qua_in_gr_rt_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_QUA_IN_GR_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_QUA_IN_GR_RT_a
  (
   p_qua_in_gr_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
end ben_QUA_IN_GR_RT_bk3;

 

/
