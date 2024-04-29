--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_DPNT_CVG_CTF_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_DPNT_CVG_CTF_BK3" AUTHID CURRENT_USER as
/* $Header: belccapi.pkh 120.0 2005/05/28 03:17:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Chg_Dpnt_Cvg_Ctf_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Chg_Dpnt_Cvg_Ctf_b
  (
   p_ler_chg_dpnt_cvg_ctfn_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Chg_Dpnt_Cvg_Ctf_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Chg_Dpnt_Cvg_Ctf_a
  (
   p_ler_chg_dpnt_cvg_ctfn_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Ler_Chg_Dpnt_Cvg_Ctf_bk3;

 

/