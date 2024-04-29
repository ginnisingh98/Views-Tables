--------------------------------------------------------
--  DDL for Package BEN_DET_ENRT_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DET_ENRT_RATES" AUTHID CURRENT_USER as
/* $Header: benraten.pkh 120.0.12010000.1 2008/07/29 12:29:22 appldev ship $ */
--
Type RtValType      is record
  (prtt_rt_val_id number
  ,rt_val         number
  ,ann_rt_val     number
  ,ecr_rt_mlt_cd  varchar2(30)
  );
--
type PRVRtVal_tab  is table of RtValType index by binary_integer;
--
procedure p_det_enrt_rates
  (p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  ,p_validate            in     boolean
  ,p_self_service_flag   in     boolean default false
  --
  ,p_prv_rtval_set          out nocopy ben_det_enrt_rates.PRVRtVal_tab
  );
--
procedure end_prtt_rt_val
  (p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  );
--
procedure end_prtt_rt_val
  (p_prtt_enrt_rslt_id   in     number
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  );
--
procedure det_enrt_rates_erl
  (p_person_id              in     number
  ,p_per_in_ler_id          in     number
  ,p_enrt_mthd_cd           in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_elig_per_elctbl_chc_id in     number
  ,p_fonm_cvg_strt_dt       in     date default null
  ,p_prtt_enrt_rslt_id      in     number
  ,p_pgm_id                 in     number
  ,p_pl_id                  in     number
  ,p_oipl_id                in     number
  ,p_enrt_cvg_strt_dt       in     date
  ,p_acty_ref_perd_cd       in     varchar2
  );


procedure set_global_enrt_rslt
  (p_prtt_enrt_rslt_id   in number);
--
procedure set_global_enrt_rt
  (p_enrt_rt_id          in number);
--
procedure clear_globals;
--
END ben_det_enrt_rates;

/
