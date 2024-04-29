--------------------------------------------------------
--  DDL for Package BEN_BNFT_POOL_RLOVR_RQMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_POOL_RLOVR_RQMT_BK3" AUTHID CURRENT_USER as
/* $Header: bebprapi.pkh 120.0 2005/05/28 00:49:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Bnft_Pool_Rlovr_Rqmt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bnft_Pool_Rlovr_Rqmt_b
  (
   p_bnft_pool_rlovr_rqmt_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Bnft_Pool_Rlovr_Rqmt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bnft_Pool_Rlovr_Rqmt_a
  (
   p_bnft_pool_rlovr_rqmt_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Bnft_Pool_Rlovr_Rqmt_bk3;

 

/
