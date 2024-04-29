--------------------------------------------------------
--  DDL for Package BEN_VRBL_RATE_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RATE_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: bevrrapi.pkh 120.0 2005/05/28 12:13:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Vrbl_Rate_Rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vrbl_Rate_Rule_b
  (
   p_vrbl_rt_rl_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Vrbl_Rate_Rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vrbl_Rate_Rule_a
  (
   p_vrbl_rt_rl_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Vrbl_Rate_Rule_bk3;

 

/
