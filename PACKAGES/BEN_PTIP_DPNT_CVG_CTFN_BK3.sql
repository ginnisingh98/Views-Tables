--------------------------------------------------------
--  DDL for Package BEN_PTIP_DPNT_CVG_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTIP_DPNT_CVG_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: bepydapi.pkh 120.0 2005/05/28 11:27:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ptip_Dpnt_Cvg_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ptip_Dpnt_Cvg_Ctfn_b
  (
   p_ptip_dpnt_cvg_ctfn_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ptip_Dpnt_Cvg_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ptip_Dpnt_Cvg_Ctfn_a
  (
   p_ptip_dpnt_cvg_ctfn_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Ptip_Dpnt_Cvg_Ctfn_bk3;

 

/
