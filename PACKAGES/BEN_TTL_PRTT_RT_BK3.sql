--------------------------------------------------------
--  DDL for Package BEN_TTL_PRTT_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TTL_PRTT_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bettpapi.pkh 120.0 2005/05/28 11:57:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ttl_prtt_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ttl_prtt_rt_b
  (
   p_ttl_prtt_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ttl_prtt_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ttl_prtt_rt_a
  (
   p_ttl_prtt_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ttl_prtt_rt_bk3;

 

/
