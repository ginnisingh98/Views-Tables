--------------------------------------------------------
--  DDL for Package BEN_VRBL_RT_PRFL_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RT_PRFL_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: bevprapi.pkh 120.0 2005/05/28 12:10:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_VRBL_RT_PRFL_RULE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_VRBL_RT_PRFL_RULE_b
  (
   p_vrbl_rt_prfl_rl_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_VRBL_RT_PRFL_RULE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_VRBL_RT_PRFL_RULE_a
  (
   p_vrbl_rt_prfl_rl_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_VRBL_RT_PRFL_RULE_bk3;

 

/
