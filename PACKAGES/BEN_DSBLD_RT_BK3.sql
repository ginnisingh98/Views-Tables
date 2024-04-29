--------------------------------------------------------
--  DDL for Package BEN_DSBLD_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSBLD_RT_BK3" AUTHID CURRENT_USER as
/* $Header: bedbrapi.pkh 120.0 2005/05/28 01:30:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSBLD_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSBLD_RT_b
  (
   p_dsbld_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSBLD_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSBLD_RT_a
  (
   p_dsbld_rt_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DSBLD_RT_bk3;

 

/
