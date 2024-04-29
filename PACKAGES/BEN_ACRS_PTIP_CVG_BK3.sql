--------------------------------------------------------
--  DDL for Package BEN_ACRS_PTIP_CVG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACRS_PTIP_CVG_BK3" AUTHID CURRENT_USER as
/* $Header: beapcapi.pkh 120.0 2005/05/28 00:24:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acrs_ptip_cvg_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acrs_ptip_cvg_b
  (
   p_acrs_ptip_cvg_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acrs_ptip_cvg_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acrs_ptip_cvg_a
  (
   p_acrs_ptip_cvg_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_acrs_ptip_cvg_bk3;

 

/
