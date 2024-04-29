--------------------------------------------------------
--  DDL for Package BEN_PSTN_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSTN_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bepstapi.pkh 120.0 2005/05/28 11:20:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PSTN_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PSTN_RT_b
  (
   p_pstn_rt_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PSTN_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PSTN_RT_a
  (
   p_pstn_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PSTN_RT_bk3;

 

/
