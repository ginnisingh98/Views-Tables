--------------------------------------------------------
--  DDL for Package BEN_BAL_TYPE_FOR_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BAL_TYPE_FOR_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bebtrapi.pkh 120.0 2005/05/28 00:52:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Bal_Type_For_Rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bal_Type_For_Rate_b
  (
   p_comp_lvl_acty_rt_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Bal_Type_For_Rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bal_Type_For_Rate_a
  (
   p_comp_lvl_acty_rt_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Bal_Type_For_Rate_bk3;

 

/
