--------------------------------------------------------
--  DDL for Package BEN_POE_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POE_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beprtapi.pkh 120.0 2005/05/28 11:13:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POE_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POE_RT_b
  (
   p_poe_rt_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POE_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POE_RT_a
  (
   p_poe_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_POE_RT_bk3;

 

/
