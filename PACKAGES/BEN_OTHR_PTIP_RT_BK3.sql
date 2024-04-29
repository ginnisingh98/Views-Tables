--------------------------------------------------------
--  DDL for Package BEN_OTHR_PTIP_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OTHR_PTIP_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beoprapi.pkh 120.0 2005/05/28 09:55:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_OTHR_PTIP_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_OTHR_PTIP_RT_b
  (
   p_othr_ptip_rt_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_OTHR_PTIP_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_OTHR_PTIP_RT_a
  (
   p_othr_ptip_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_OTHR_PTIP_RT_bk3;

 

/
