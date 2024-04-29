--------------------------------------------------------
--  DDL for Package BEN_ELIG_CVRD_DPNT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CVRD_DPNT_BK3" AUTHID CURRENT_USER as
/* $Header: bepdpapi.pkh 120.0.12000000.1 2007/01/19 20:54:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CVRD_DPNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CVRD_DPNT_b
  (
   p_elig_cvrd_dpnt_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CVRD_DPNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CVRD_DPNT_a
  (
   p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_CVRD_DPNT_bk3;

 

/
