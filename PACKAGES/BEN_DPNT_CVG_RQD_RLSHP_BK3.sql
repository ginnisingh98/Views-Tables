--------------------------------------------------------
--  DDL for Package BEN_DPNT_CVG_RQD_RLSHP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_CVG_RQD_RLSHP_BK3" AUTHID CURRENT_USER as
/* $Header: bedcrapi.pkh 120.0 2005/05/28 01:34:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVG_RQD_RLSHP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVG_RQD_RLSHP_b
  (
   p_dpnt_cvg_rqd_rlshp_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DPNT_CVG_RQD_RLSHP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVG_RQD_RLSHP_a
  (
   p_dpnt_cvg_rqd_rlshp_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DPNT_CVG_RQD_RLSHP_bk3;

 

/
