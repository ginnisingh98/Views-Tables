--------------------------------------------------------
--  DDL for Package BEN_MNG_DPNT_BNF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MNG_DPNT_BNF" AUTHID CURRENT_USER as
/* $Header: benmndep.pkh 120.1 2006/09/12 12:34:19 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< recycle_dpnt_bnf >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
-- Post Success:
--
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure recycle_dpnt_bnf
  (p_validate                       in boolean default false
  ,p_new_prtt_enrt_rslt_id          in number
  ,p_new_enrt_rslt_ovn              in out nocopy number
  ,p_old_prtt_enrt_rslt_id          in number
  ,p_new_elig_per_elctbl_chc_id     in number
  ,p_person_id                      in number
  ,p_return_to_exist_cvg_flag       in varchar2
  ,p_old_pl_id                      in number
  ,p_new_pl_id                      in number
  ,p_old_oipl_id                    in number
  ,p_new_oipl_id                    in number
  ,p_old_pl_typ_id                  in number
  ,p_new_pl_typ_id                  in number
  ,p_pgm_id                         in number
  ,p_ler_id                         in number
  ,p_per_in_ler_id                  in number default null
  ,p_dpnt_cvg_strt_dt_cd            in varchar2
  ,p_dpnt_cvg_strt_dt_rl            in number
  ,p_enrt_cvg_strt_dt               in date
  ,p_business_group_id              in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_multi_row_actn                 in boolean default false
  ,p_process_dpnt                   in boolean default true
  ,p_process_bnf                    in boolean default true);
--
Procedure hook_dpnt
  (p_validate                 in boolean default false
  ,p_elig_dpnt_id             in number
  ,p_prtt_enrt_rslt_id        in number
  ,p_old_prtt_enrt_rslt_id    in number
  ,p_new_enrt_rslt_ovn        in out nocopy number
  ,p_pgm_id                   in number
  ,p_cvg_strt_dt              in date
  ,p_effective_date           in date
  ,p_old_elig_cvrd_dpnt_id    in number
  ,p_per_in_ler_id            in number
  ,p_business_group_id        in number
  ,p_datetrack_mode           in varchar2
  ,p_multi_row_actn           in BOOLEAN default FALSE);
--
end ben_mng_dpnt_bnf;

/
