--------------------------------------------------------
--  DDL for Package BEN_OPTD_MDCR_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTD_MDCR_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beomrapi.pkh 120.0 2005/05/28 09:51:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_OPTD_MDCR_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_OPTD_MDCR_RT_b
  (
   p_optd_mdcr_rt_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_OPTD_MDCR_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_OPTD_MDCR_RT_a
  (
   p_optd_mdcr_rt_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_OPTD_MDCR_RT_bk3;

 

/
