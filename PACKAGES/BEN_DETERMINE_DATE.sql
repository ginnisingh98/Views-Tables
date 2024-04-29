--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_DATE" AUTHID CURRENT_USER as
/* $Header: bendetdt.pkh 120.3.12010000.1 2008/07/29 12:09:35 appldev ship $ */
--
g_package              varchar2(80)  := 'ben_determine_date';
--
g_def_curr_pgm_rec     ben_pgm_f%rowtype;
g_def_curr_ptip_rec    ben_ptip_f%rowtype;
g_def_curr_plip_rec    ben_plip_f%rowtype;
g_def_curr_pl_rec      ben_pl_f%rowtype;
g_dep_rec              ben_type.g_report_rec;
--
g_ben_disp_ff_warn_msg varchar2(10); /* To store the value of profile BEN_DISP_FF_WARN_MSG */
--
procedure main
  (p_cache_mode             in     boolean  default false
  --
  ,p_date_cd                in     varchar2
  ,p_per_in_ler_id          in     number   default null
  ,p_person_id              in     number   default null
  ,p_pgm_id                 in     number   default null
  ,p_pl_id                  in     number   default null
  ,p_oipl_id                in     number   default null
  ,p_elig_per_elctbl_chc_id in     number   default null -- optional for all
  ,p_business_group_id      in     number   default null
  ,p_formula_id             in     number   default null
  ,p_acty_base_rt_id        in     number   default null -- as a context to formula calls
  ,p_bnfts_bal_id           in     number   default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date     default null
  ,p_start_date             in     date     default null
  ,p_returned_date             out nocopy date
  ,p_parent_person_id       in     number  default null
-- Added two more parameters to fix the Bug 1531647
  ,p_param1		    in     varchar2 default null
  ,p_param1_value           in     varchar2 default null
-- Added for new dpnt_cvg_end_dt_cd PECED
  ,p_enrt_cvg_end_dt        in     date default null
  ,p_comp_obj_mode          in     boolean default true
  ,p_fonm_cvg_strt_dt       in  date default null
  ,p_fonm_rt_strt_dt        in  date default null
  ,p_cmpltd_dt              in  date default null
  );
procedure rate_and_coverage_dates
  (p_cache_mode             in     boolean default false
  --
  -- Cache related parameters
  --
  ,p_pgm_row                in     ben_cobj_cache.g_pgm_inst_row
  := ben_cobj_cache.g_pgm_default_row
  ,p_ptip_row               in     ben_cobj_cache.g_ptip_inst_row
  := ben_cobj_cache.g_ptip_default_row
  ,p_plip_row               in     ben_cobj_cache.g_plip_inst_row
  := ben_cobj_cache.g_plip_default_row
  ,p_pl_row                 in     ben_cobj_cache.g_pl_inst_row
  := ben_cobj_cache.g_pl_default_row
  --
  ,p_per_in_ler_id          in     number  default null
  ,p_person_id              in     number  default null
  ,p_pgm_id                 in     number  default null
  ,p_pl_id                  in     number  default null
  ,p_oipl_id                in     number  default null
  ,p_par_ptip_id            in     number  default null
  ,p_par_plip_id            in     number  default null
  ,p_lee_rsn_id             in     number  default null
  ,p_enrt_perd_id           in     number  default null
  ,p_enrt_perd_for_pl_id    in     number  default null
  --
             -- which dates is R for rate, C for coverage, B for both
  ,p_which_dates_cd         in     varchar2      default 'B'
             -- will error if Y and an absolute date not found
             --   Note: codes must allways be found.
  ,p_date_mandatory_flag    in     varchar2      default 'Y'
             -- compute_dates_flag is Y for compute dates, N for Don't
  ,p_compute_dates_flag     in     varchar2      default 'Y'
             --
             -- optional for everything
             --
  ,p_elig_per_elctbl_chc_id in     number  default null
  ,p_acty_base_rt_id        in     number  default null
  ,p_business_group_id      in     number
  ,p_start_date             in     date    default null
  ,p_end_date               in     date    default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date    default null
  --
  ,p_enrt_cvg_strt_dt          out nocopy date
  ,p_enrt_cvg_strt_dt_cd       out nocopy varchar2
  ,p_enrt_cvg_strt_dt_rl       out nocopy number
  ,p_rt_strt_dt                out nocopy date
  ,p_rt_strt_dt_cd             out nocopy varchar2
  ,p_rt_strt_dt_rl             out nocopy number
  ,p_enrt_cvg_end_dt           out nocopy date
  ,p_enrt_cvg_end_dt_cd        out nocopy varchar2
  ,p_enrt_cvg_end_dt_rl        out nocopy number
  ,p_rt_end_dt                 out nocopy date
  ,p_rt_end_dt_cd              out nocopy varchar2
  ,p_rt_end_dt_rl              out nocopy number
  );
  --
  function do_date_at_enrollment(p_date_cd in varchar2) return boolean;
  --
  --overrident procedure call for calling from PLD for override enrollment
procedure rate_and_coverage_dates_nc
  (p_per_in_ler_id          in     number  default null
  ,p_person_id              in     number  default null
  ,p_pgm_id                 in     number  default null
  ,p_pl_id                  in     number  default null
  ,p_oipl_id                in     number  default null
  ,p_par_ptip_id            in     number  default null
  ,p_par_plip_id            in     number  default null
  ,p_lee_rsn_id             in     number  default null
  ,p_enrt_perd_id           in     number  default null
  ,p_enrt_perd_for_pl_id    in     number  default null
  ,p_which_dates_cd         in     varchar2      default 'B'
  ,p_date_mandatory_flag    in     varchar2      default 'Y'
  ,p_compute_dates_flag     in     varchar2      default 'Y'
  ,p_elig_per_elctbl_chc_id in     number  default null
  ,p_acty_base_rt_id        in     number  default null
  ,p_business_group_id      in     number
  ,p_start_date             in     date    default null
  ,p_end_date               in     date    default null
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date    default null
  ,p_enrt_cvg_strt_dt          out nocopy date
  ,p_enrt_cvg_strt_dt_cd       out nocopy varchar2
  ,p_enrt_cvg_strt_dt_rl       out nocopy number
  ,p_rt_strt_dt                out nocopy date
  ,p_rt_strt_dt_cd             out nocopy varchar2
  ,p_rt_strt_dt_rl             out nocopy number
  ,p_enrt_cvg_end_dt           out nocopy date
  ,p_enrt_cvg_end_dt_cd        out nocopy varchar2
  ,p_enrt_cvg_end_dt_rl        out nocopy number
  ,p_rt_end_dt                 out nocopy date
  ,p_rt_end_dt_cd              out nocopy varchar2
  ,p_rt_end_dt_rl              out nocopy number
  );
  --
end ben_determine_date;

/
