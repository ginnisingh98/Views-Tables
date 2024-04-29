--------------------------------------------------------
--  DDL for Package BEN_ELIGIBILITY_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBILITY_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: becerapi.pkh 120.0 2005/05/28 01:00:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGIBILITY_RULE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGIBILITY_RULE_b
  (
   p_prtn_eligy_rl_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGIBILITY_RULE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGIBILITY_RULE_a
  (
   p_prtn_eligy_rl_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIGIBILITY_RULE_bk3;

 

/