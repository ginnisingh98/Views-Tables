--------------------------------------------------------
--  DDL for Package BEN_PLAN_DPNT_CVG_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DPNT_CVG_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: bepndapi.pkh 120.0 2005/05/28 10:55:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Dpnt_Cvg_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Dpnt_Cvg_Ctfn_b
  (
   p_pl_dpnt_cvg_ctfn_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Dpnt_Cvg_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Dpnt_Cvg_Ctfn_a
  (
   p_pl_dpnt_cvg_ctfn_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_Dpnt_Cvg_Ctfn_bk3;

 

/
