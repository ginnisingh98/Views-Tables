--------------------------------------------------------
--  DDL for Package BEN_GENERATE_COMMUNICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GENERATE_COMMUNICATIONS" AUTHID CURRENT_USER as
/* $Header: bencommu.pkh 120.0.12000000.1 2007/01/19 15:14:09 appldev noship $ */
  --
  g_commu_rec       ben_type.g_batch_commu_rec;
  g_comm_generated  boolean;
  --
  g_comm_start_date date;
  g_to_be_sent_dt   date;
  --
  procedure main
    (p_person_id             in number,
     p_cm_trgr_typ_cd        in varchar2 default null,
     p_cm_typ_id             in number   default null,
     p_ler_id                in number   default null,
     p_per_in_ler_id         in number   default null,
     p_prtt_enrt_actn_id     in number   default null,
     p_bnf_person_id         in number   default null,
     p_dpnt_person_id        in number   default null,
     -- PB : 5422 :
     -- p_enrt_perd_id          in number   default null,
     p_asnd_lf_evt_dt        in date     default null,
     p_actn_typ_id           in number   default null,
     p_enrt_mthd_cd          in varchar2 default null,
     p_pgm_id                in number   default null,
     p_pl_id                 in number   default null,
     p_pl_typ_id             in number   default null,
     p_rqstbl_untl_dt        in date     default null,
     p_business_group_id     in number,
     p_proc_cd1              in varchar2 default null,
     p_proc_cd2              in varchar2 default null,
     p_proc_cd3              in varchar2 default null,
     p_proc_cd4              in varchar2 default null,
     p_proc_cd5              in varchar2 default null,
     p_proc_cd6              in varchar2 default null,
     p_proc_cd7              in varchar2 default null,
     p_proc_cd8              in varchar2 default null,
     p_proc_cd9              in varchar2 default null,
     p_proc_cd10             in varchar2 default null,
     p_effective_date        in date,
     p_lf_evt_ocrd_dt        in date     default null,
     p_mode                  in varchar2 default 'I',
     p_source                in varchar2 default null);
  --
  procedure populate_working_tables
    (p_person_id             in number,
     p_cm_typ_id             in number,
     p_business_group_id     in number,
     p_effective_date        in date,
     p_cm_trgr_id            in number,
     p_inspn_rqd_flag        in varchar2,
     p_cm_dlvry_med_cd       in varchar2,
     p_cm_dlvry_mthd_cd      in varchar2,
     p_per_cm_id             in number,
     p_mode                  in varchar2 default 'I');
  --
  procedure pop_ben_per_cm_usg_f
    (p_per_cm_id             in  number,
     p_cm_typ_usg_id         in  number,
     p_business_group_id     in  number,
     p_effective_date        in  date,
     p_per_cm_usg_id         out nocopy number,
     p_usage_created         out nocopy boolean);
  --
  procedure pop_ben_per_cm_f
    (p_person_id             in  number,
     p_ler_id                in  number,
     p_per_in_ler_id         in  number,
     p_prtt_enrt_actn_id     in  number,
     p_bnf_person_id         in  number,
     p_dpnt_person_id        in  number,
     p_cm_typ_id             in  number,
     p_lf_evt_ocrd_dt        in  date,
     p_rqstbl_untl_dt        in  date,
     p_business_group_id     in  number,
     p_effective_date        in  date,
     p_date_cd               in  varchar2,
     p_formula_id            in  number,
     p_pgm_id                in  number,
     p_pl_id                 in  number,
     p_per_cm_id             out nocopy number);
  --
  function get_cvg_strt_dt (p_elig_per_id number,
                            p_per_in_ler_id number)
  return date;

  pragma restrict_references(get_cvg_strt_dt,WNDS,WNPS);

end ben_generate_communications;
--

 

/
