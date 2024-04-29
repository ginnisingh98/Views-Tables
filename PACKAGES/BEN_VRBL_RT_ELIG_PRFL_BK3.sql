--------------------------------------------------------
--  DDL for Package BEN_VRBL_RT_ELIG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RT_ELIG_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: bevepapi.pkh 120.0 2005/05/28 12:02:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vrbl_rt_elig_prfl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vrbl_rt_elig_prfl_b
  (
   p_vrbl_rt_elig_prfl_id                       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vrbl_rt_elig_prfl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vrbl_rt_elig_prfl_a
  (
   p_vrbl_rt_elig_prfl_id                       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_vrbl_rt_elig_prfl_bk3;

 

/
