--------------------------------------------------------
--  DDL for Package BEN_ELIGY_PROFILE_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_PROFILE_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: beerlapi.pkh 120.0 2005/05/28 02:52:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGY_PROFILE_RULE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGY_PROFILE_RULE_b
  (
   p_eligy_prfl_rl_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGY_PROFILE_RULE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGY_PROFILE_RULE_a
  (
   p_eligy_prfl_rl_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIGY_PROFILE_RULE_bk3;

 

/
