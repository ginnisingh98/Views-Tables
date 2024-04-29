--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_PRVDR_POOL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_PRVDR_POOL_BK3" AUTHID CURRENT_USER as
/* $Header: bebppapi.pkh 120.0 2005/05/28 00:48:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefit_Prvdr_Pool_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdr_Pool_b
  (
   p_bnft_prvdr_pool_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefit_Prvdr_Pool_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdr_Pool_a
  (
   p_bnft_prvdr_pool_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Benefit_Prvdr_Pool_bk3;

 

/
