--------------------------------------------------------
--  DDL for Package BEN_PIL_ELCTBL_CHC_POPL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ELCTBL_CHC_POPL_BK1" AUTHID CURRENT_USER as
/* $Header: bepelapi.pkh 120.1 2007/05/13 23:05:21 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Pil_Elctbl_chc_Popl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Pil_Elctbl_chc_Popl_b
  (
   p_dflt_enrt_dt                   in  date
  ,p_dflt_asnd_dt                   in  date
  ,p_elcns_made_dt                  in  date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2
  ,p_enrt_typ_cycl_cd               in  varchar2
  ,p_enrt_perd_end_dt               in  date
  ,p_enrt_perd_strt_dt              in  date
  ,p_procg_end_dt                   in  date
  ,p_pil_elctbl_popl_stat_cd        in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_uom                            in  varchar2
  ,p_comments                            in  varchar2
  ,p_mgr_ovrid_dt                            in  date
  ,p_ws_mgr_id                            in  number
  ,p_mgr_ovrid_person_id                            in  number
  ,p_assignment_id                            in  number
 --cwb
 ,p_bdgt_acc_cd                   in varchar2
 ,p_pop_cd                        in varchar2
 ,p_bdgt_due_dt                   in date
 ,p_bdgt_export_flag              in varchar2
 ,p_bdgt_iss_dt                   in date
 ,p_bdgt_stat_cd                  in varchar2
 ,p_ws_acc_cd                     in varchar2
 ,p_ws_due_dt                     in date
 ,p_ws_export_flag                in varchar2
 ,p_ws_iss_dt                     in date
 ,p_ws_stat_cd                    in varchar2
 --cwb
  ,p_reinstate_cd                   in varchar2
  ,p_reinstate_ovrdn_cd             in varchar2
  ,p_auto_asnd_dt                   in  date
  ,p_cbr_elig_perd_strt_dt          in  date
  ,p_cbr_elig_perd_end_dt           in  date
  ,p_lee_rsn_id                     in  number
  ,p_enrt_perd_id                   in  number
  ,p_per_in_ler_id                  in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_pel_attribute_category         in  varchar2
  ,p_pel_attribute1                 in  varchar2
  ,p_pel_attribute2                 in  varchar2
  ,p_pel_attribute3                 in  varchar2
  ,p_pel_attribute4                 in  varchar2
  ,p_pel_attribute5                 in  varchar2
  ,p_pel_attribute6                 in  varchar2
  ,p_pel_attribute7                 in  varchar2
  ,p_pel_attribute8                 in  varchar2
  ,p_pel_attribute9                 in  varchar2
  ,p_pel_attribute10                in  varchar2
  ,p_pel_attribute11                in  varchar2
  ,p_pel_attribute12                in  varchar2
  ,p_pel_attribute13                in  varchar2
  ,p_pel_attribute14                in  varchar2
  ,p_pel_attribute15                in  varchar2
  ,p_pel_attribute16                in  varchar2
  ,p_pel_attribute17                in  varchar2
  ,p_pel_attribute18                in  varchar2
  ,p_pel_attribute19                in  varchar2
  ,p_pel_attribute20                in  varchar2
  ,p_pel_attribute21                in  varchar2
  ,p_pel_attribute22                in  varchar2
  ,p_pel_attribute23                in  varchar2
  ,p_pel_attribute24                in  varchar2
  ,p_pel_attribute25                in  varchar2
  ,p_pel_attribute26                in  varchar2
  ,p_pel_attribute27                in  varchar2
  ,p_pel_attribute28                in  varchar2
  ,p_pel_attribute29                in  varchar2
  ,p_pel_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date
  ,p_defer_deenrol_flag             in varchar2
  ,p_deenrol_made_dt                in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Pil_Elctbl_chc_Popl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Pil_Elctbl_chc_Popl_a
  (
   p_pil_elctbl_chc_popl_id         in  number
  ,p_dflt_enrt_dt                   in  date
  ,p_dflt_asnd_dt                   in  date
  ,p_elcns_made_dt                  in  date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2
  ,p_enrt_typ_cycl_cd               in  varchar2
  ,p_enrt_perd_end_dt               in  date
  ,p_enrt_perd_strt_dt              in  date
  ,p_procg_end_dt                   in  date
  ,p_pil_elctbl_popl_stat_cd        in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_uom                            in  varchar2
  ,p_comments                            in  varchar2
  ,p_mgr_ovrid_dt                            in  date
  ,p_ws_mgr_id                            in  number
  ,p_mgr_ovrid_person_id                            in  number
  ,p_assignment_id                            in  number
 --cwb
 ,p_bdgt_acc_cd                   in varchar2
 ,p_pop_cd                        in varchar2
 ,p_bdgt_due_dt                   in date
 ,p_bdgt_export_flag              in varchar2
 ,p_bdgt_iss_dt                   in date
 ,p_bdgt_stat_cd                  in varchar2
 ,p_ws_acc_cd                     in varchar2
 ,p_ws_due_dt                     in date
 ,p_ws_export_flag                in varchar2
 ,p_ws_iss_dt                     in date
 ,p_ws_stat_cd                    in varchar2
 --cwb
  ,p_reinstate_cd                   in varchar2
  ,p_reinstate_ovrdn_cd             in varchar2
  ,p_auto_asnd_dt                   in  date
  ,p_cbr_elig_perd_strt_dt          in  date
  ,p_cbr_elig_perd_end_dt           in  date
  ,p_lee_rsn_id                     in  number
  ,p_enrt_perd_id                   in  number
  ,p_per_in_ler_id                  in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_pel_attribute_category         in  varchar2
  ,p_pel_attribute1                 in  varchar2
  ,p_pel_attribute2                 in  varchar2
  ,p_pel_attribute3                 in  varchar2
  ,p_pel_attribute4                 in  varchar2
  ,p_pel_attribute5                 in  varchar2
  ,p_pel_attribute6                 in  varchar2
  ,p_pel_attribute7                 in  varchar2
  ,p_pel_attribute8                 in  varchar2
  ,p_pel_attribute9                 in  varchar2
  ,p_pel_attribute10                in  varchar2
  ,p_pel_attribute11                in  varchar2
  ,p_pel_attribute12                in  varchar2
  ,p_pel_attribute13                in  varchar2
  ,p_pel_attribute14                in  varchar2
  ,p_pel_attribute15                in  varchar2
  ,p_pel_attribute16                in  varchar2
  ,p_pel_attribute17                in  varchar2
  ,p_pel_attribute18                in  varchar2
  ,p_pel_attribute19                in  varchar2
  ,p_pel_attribute20                in  varchar2
  ,p_pel_attribute21                in  varchar2
  ,p_pel_attribute22                in  varchar2
  ,p_pel_attribute23                in  varchar2
  ,p_pel_attribute24                in  varchar2
  ,p_pel_attribute25                in  varchar2
  ,p_pel_attribute26                in  varchar2
  ,p_pel_attribute27                in  varchar2
  ,p_pel_attribute28                in  varchar2
  ,p_pel_attribute29                in  varchar2
  ,p_pel_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_defer_deenrol_flag             in varchar2
  ,p_deenrol_made_dt                in date
  );
--
end ben_Pil_Elctbl_chc_Popl_bk1;

/
