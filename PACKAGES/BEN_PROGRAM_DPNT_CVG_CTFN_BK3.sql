--------------------------------------------------------
--  DDL for Package BEN_PROGRAM_DPNT_CVG_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROGRAM_DPNT_CVG_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: bepgcapi.pkh 120.0 2005/05/28 10:44:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Program_Dpnt_Cvg_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Program_Dpnt_Cvg_Ctfn_b
  (
   p_pgm_dpnt_cvg_ctfn_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Program_Dpnt_Cvg_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Program_Dpnt_Cvg_Ctfn_a
  (
   p_pgm_dpnt_cvg_ctfn_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Program_Dpnt_Cvg_Ctfn_bk3;

 

/
