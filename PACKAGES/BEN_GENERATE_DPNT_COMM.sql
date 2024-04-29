--------------------------------------------------------
--  DDL for Package BEN_GENERATE_DPNT_COMM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GENERATE_DPNT_COMM" AUTHID CURRENT_USER as
/* $Header: bencomde.pkh 120.0.12010000.1 2008/07/29 12:04:44 appldev ship $ */
  --
  procedure main
    (p_proc_cd           in varchar2,
     p_name              in varchar2,
     p_rcpent_cd         in varchar2,
     p_person_id         in number,
     p_per_in_ler_id     in number,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_prtt_enrt_actn_id in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_enrt_mthd_cd      in varchar2,
     p_actn_typ_id       in number,
     p_per_cm_id         in number,
     p_cm_trgr_id        in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_cm_typ_id         in number,
     p_ler_id            in number,
     p_date_cd           in varchar2,
     p_inspn_rqd_flag    in varchar2,
     p_formula_id        in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_rqstbl_untl_dt    in date,
     p_cm_dlvry_med_cd   in varchar2,
     p_cm_dlvry_mthd_cd  in varchar2,
     p_whnvr_trgrd_flag  in varchar2,
     p_source            in varchar2);
  --
end ben_generate_dpnt_comm;
--

/
