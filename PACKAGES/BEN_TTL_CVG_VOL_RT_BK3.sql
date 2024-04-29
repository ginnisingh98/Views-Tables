--------------------------------------------------------
--  DDL for Package BEN_TTL_CVG_VOL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TTL_CVG_VOL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: betcvapi.pkh 120.0 2005/05/28 11:55:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ttl_cvg_vol_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ttl_cvg_vol_rt_b
  (
   p_ttl_cvg_vol_rt_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ttl_cvg_vol_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ttl_cvg_vol_rt_a
  (
   p_ttl_cvg_vol_rt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ttl_cvg_vol_rt_bk3;

 

/
