--------------------------------------------------------
--  DDL for Package BEN_PQC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PQC_RKU" AUTHID CURRENT_USER as
/* $Header: bepqcrhi.pkh 120.0.12010000.1 2008/07/29 12:53:03 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_prtt_rmt_rqst_ctfn_prvdd_id  in number
  ,p_prtt_clm_gd_or_svc_typ_id    in number
  ,p_pl_gd_r_svc_ctfn_id          in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_reimbmt_ctfn_rqd_flag        in varchar2
  ,p_business_group_id            in number
  ,p_prtt_enrt_actn_id            in number
  ,p_reimbmt_ctfn_recd_dt         in date
  ,p_reimbmt_ctfn_dnd_dt          in date
  ,p_reimbmt_ctfn_typ_cd          in varchar2
  ,p_pqc_attribute_category       in varchar2
  ,p_pqc_attribute1               in varchar2
  ,p_pqc_attribute2               in varchar2
  ,p_pqc_attribute3               in varchar2
  ,p_pqc_attribute4               in varchar2
  ,p_pqc_attribute5               in varchar2
  ,p_pqc_attribute6               in varchar2
  ,p_pqc_attribute7               in varchar2
  ,p_pqc_attribute8               in varchar2
  ,p_pqc_attribute9               in varchar2
  ,p_pqc_attribute10              in varchar2
  ,p_pqc_attribute11              in varchar2
  ,p_pqc_attribute12              in varchar2
  ,p_pqc_attribute13              in varchar2
  ,p_pqc_attribute14              in varchar2
  ,p_pqc_attribute15              in varchar2
  ,p_pqc_attribute16              in varchar2
  ,p_pqc_attribute17              in varchar2
  ,p_pqc_attribute18              in varchar2
  ,p_pqc_attribute19              in varchar2
  ,p_pqc_attribute20              in varchar2
  ,p_pqc_attribute21              in varchar2
  ,p_pqc_attribute22              in varchar2
  ,p_pqc_attribute23              in varchar2
  ,p_pqc_attribute24              in varchar2
  ,p_pqc_attribute25              in varchar2
  ,p_pqc_attribute26              in varchar2
  ,p_pqc_attribute27              in varchar2
  ,p_pqc_attribute28              in varchar2
  ,p_pqc_attribute29              in varchar2
  ,p_pqc_attribute30              in varchar2
  ,p_object_version_number        in number
  ,p_prtt_clm_gd_or_svc_typ_id_o  in number
  ,p_pl_gd_r_svc_ctfn_id_o        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_reimbmt_ctfn_rqd_flag_o      in varchar2
  ,p_business_group_id_o          in number
  ,p_prtt_enrt_actn_id_o          in number
  ,p_reimbmt_ctfn_recd_dt_o       in date
  ,p_reimbmt_ctfn_dnd_dt_o        in date
  ,p_reimbmt_ctfn_typ_cd_o        in varchar2
  ,p_pqc_attribute_category_o     in varchar2
  ,p_pqc_attribute1_o             in varchar2
  ,p_pqc_attribute2_o             in varchar2
  ,p_pqc_attribute3_o             in varchar2
  ,p_pqc_attribute4_o             in varchar2
  ,p_pqc_attribute5_o             in varchar2
  ,p_pqc_attribute6_o             in varchar2
  ,p_pqc_attribute7_o             in varchar2
  ,p_pqc_attribute8_o             in varchar2
  ,p_pqc_attribute9_o             in varchar2
  ,p_pqc_attribute10_o            in varchar2
  ,p_pqc_attribute11_o            in varchar2
  ,p_pqc_attribute12_o            in varchar2
  ,p_pqc_attribute13_o            in varchar2
  ,p_pqc_attribute14_o            in varchar2
  ,p_pqc_attribute15_o            in varchar2
  ,p_pqc_attribute16_o            in varchar2
  ,p_pqc_attribute17_o            in varchar2
  ,p_pqc_attribute18_o            in varchar2
  ,p_pqc_attribute19_o            in varchar2
  ,p_pqc_attribute20_o            in varchar2
  ,p_pqc_attribute21_o            in varchar2
  ,p_pqc_attribute22_o            in varchar2
  ,p_pqc_attribute23_o            in varchar2
  ,p_pqc_attribute24_o            in varchar2
  ,p_pqc_attribute25_o            in varchar2
  ,p_pqc_attribute26_o            in varchar2
  ,p_pqc_attribute27_o            in varchar2
  ,p_pqc_attribute28_o            in varchar2
  ,p_pqc_attribute29_o            in varchar2
  ,p_pqc_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_pqc_rku;

/
