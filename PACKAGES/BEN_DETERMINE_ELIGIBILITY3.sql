--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ELIGIBILITY3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ELIGIBILITY3" AUTHID CURRENT_USER as
/* $Header: bendete3.pkh 120.1 2006/01/30 10:53:28 mhoyes noship $ */
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
procedure check_dsgn_rqmts
  (p_oipl_id           in  number
  ,p_pl_id             in  number
  ,p_opt_id            in  number
  ,p_person_id         in  number
  ,p_business_group_id in  number
  ,p_lf_evt_ocrd_dt    in  date
  ,p_effective_date    in  date
  ,p_vrfy_fmm          in  boolean
  ,p_dpnt_elig_flag    out nocopy varchar2
  );
function get_prtn_st_dt_aftr_wtg
  (p_person_id           in     number
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  ,p_prtn_eff_strt_dt_cd in     varchar2
  ,p_prtn_eff_strt_dt_rl in     number
  ,p_wtg_perd_cmpltn_dt  in     date
  ,p_pl_id               in     number
  ,p_pl_typ_id           in     number
  ,p_pgm_id              in     number
  ,p_oipl_id             in     number
  ,p_plip_id             in     number
  ,p_ptip_id             in     number
  ,p_opt_id              in     number
  )
return date;
procedure save_to_restore
  (p_current_per_in_ler_id   NUMBER,
   p_per_in_ler_id           NUMBER,
   p_elig_per_id             NUMBER,
   p_elig_per_opt_id         NUMBER,
   p_effective_date          DATE
  );
end ben_determine_eligibility3;

 

/
