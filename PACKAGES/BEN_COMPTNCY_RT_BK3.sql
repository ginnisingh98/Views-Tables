--------------------------------------------------------
--  DDL for Package BEN_COMPTNCY_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMPTNCY_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bectyapi.pkh 120.0 2005/05/28 01:28:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comptncy_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comptncy_rt_b
  (
   p_comptncy_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comptncy_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comptncy_rt_a
  (
   p_comptncy_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
end ben_comptncy_rt_bk3;

 

/
