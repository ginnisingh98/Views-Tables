--------------------------------------------------------
--  DDL for Package BEN_BNFT_VRBL_RT_RL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_VRBL_RT_RL_BK3" AUTHID CURRENT_USER as
/* $Header: bebrrapi.pkh 120.0 2005/05/28 00:52:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bnft_vrbl_rt_rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt_rl_b
  (
   p_bnft_vrbl_rt_rl_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bnft_vrbl_rt_rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt_rl_a
  (
   p_bnft_vrbl_rt_rl_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_bnft_vrbl_rt_rl_bk3;

 

/
