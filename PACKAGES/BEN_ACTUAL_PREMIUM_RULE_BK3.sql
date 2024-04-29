--------------------------------------------------------
--  DDL for Package BEN_ACTUAL_PREMIUM_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTUAL_PREMIUM_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: beavaapi.pkh 120.0 2005/05/28 00:31:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_actual_premium_rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_actual_premium_rule_b
  (
   p_actl_prem_vrbl_rt_rl_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_actual_premium_rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_actual_premium_rule_a
  (
   p_actl_prem_vrbl_rt_rl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_actual_premium_rule_bk3;

 

/
