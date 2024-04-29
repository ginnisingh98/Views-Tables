--------------------------------------------------------
--  DDL for Package BEN_LVG_RSN_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LVG_RSN_RT_BK3" AUTHID CURRENT_USER as
/* $Header: belrnapi.pkh 120.0 2005/05/28 03:35:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_lvg_rsn_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lvg_rsn_rt_b
  (
   p_lvg_rsn_rt_id             	  in  number
  ,p_object_version_number        in  number
  ,p_effective_date               in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_lvg_rsn_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lvg_rsn_rt_a
  (
   p_lvg_rsn_rt_id           	    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
end ben_lvg_rsn_rt_bk3;

 

/
