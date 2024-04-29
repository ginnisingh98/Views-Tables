--------------------------------------------------------
--  DDL for Package BEN_APLCN_TO_BENEFIT_POOL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APLCN_TO_BENEFIT_POOL_BK3" AUTHID CURRENT_USER as
/* $Header: beabpapi.pkh 120.0 2005/05/28 00:17:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Aplcn_To_Benefit_Pool_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Aplcn_To_Benefit_Pool_b
  (
   p_aplcn_to_bnft_pool_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Aplcn_To_Benefit_Pool_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Aplcn_To_Benefit_Pool_a
  (
   p_aplcn_to_bnft_pool_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Aplcn_To_Benefit_Pool_bk3;

 

/
