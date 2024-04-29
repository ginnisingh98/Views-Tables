--------------------------------------------------------
--  DDL for Package BEN_BNFT_VRBL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_VRBL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bebvrapi.pkh 120.0 2005/05/28 00:54:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bnft_vrbl_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt_b
  (
   p_bnft_vrbl_rt_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_bnft_vrbl_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt_a
  (
   p_bnft_vrbl_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_bnft_vrbl_rt_bk3;

 

/
