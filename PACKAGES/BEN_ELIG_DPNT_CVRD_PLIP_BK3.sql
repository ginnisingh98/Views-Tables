--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_CVRD_PLIP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_CVRD_PLIP_BK3" AUTHID CURRENT_USER as
/* $Header: beediapi.pkh 120.0 2005/05/28 01:59:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVRD_PLIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVRD_PLIP_b
  (
   p_elig_dpnt_cvrd_plip_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_DPNT_CVRD_PLIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVRD_PLIP_a
  (
   p_elig_dpnt_cvrd_plip_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_DPNT_CVRD_PLIP_bk3;

 

/
