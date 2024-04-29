--------------------------------------------------------
--  DDL for Package BEN_PCS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCS_RKD" AUTHID CURRENT_USER as
/* $Header: bepcsrhi.pkh 120.0 2005/05/28 10:17:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtt_enrt_ctfn_prvdd_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_enrt_ctfn_rqd_flag_o           in varchar2
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_enrt_ctfn_recd_dt_o            in date
 ,p_enrt_ctfn_dnd_dt_o             in date
 ,p_enrt_r_bnft_ctfn_cd_o          in varchar2
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_prtt_enrt_actn_id_o            in number
 ,p_business_group_id_o            in number
 ,p_pcs_attribute_category_o       in varchar2
 ,p_pcs_attribute1_o               in varchar2
 ,p_pcs_attribute2_o               in varchar2
 ,p_pcs_attribute3_o               in varchar2
 ,p_pcs_attribute4_o               in varchar2
 ,p_pcs_attribute5_o               in varchar2
 ,p_pcs_attribute6_o               in varchar2
 ,p_pcs_attribute7_o               in varchar2
 ,p_pcs_attribute8_o               in varchar2
 ,p_pcs_attribute9_o               in varchar2
 ,p_pcs_attribute10_o              in varchar2
 ,p_pcs_attribute11_o              in varchar2
 ,p_pcs_attribute12_o              in varchar2
 ,p_pcs_attribute13_o              in varchar2
 ,p_pcs_attribute14_o              in varchar2
 ,p_pcs_attribute15_o              in varchar2
 ,p_pcs_attribute16_o              in varchar2
 ,p_pcs_attribute17_o              in varchar2
 ,p_pcs_attribute18_o              in varchar2
 ,p_pcs_attribute19_o              in varchar2
 ,p_pcs_attribute20_o              in varchar2
 ,p_pcs_attribute21_o              in varchar2
 ,p_pcs_attribute22_o              in varchar2
 ,p_pcs_attribute23_o              in varchar2
 ,p_pcs_attribute24_o              in varchar2
 ,p_pcs_attribute25_o              in varchar2
 ,p_pcs_attribute26_o              in varchar2
 ,p_pcs_attribute27_o              in varchar2
 ,p_pcs_attribute28_o              in varchar2
 ,p_pcs_attribute29_o              in varchar2
 ,p_pcs_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pcs_rkd;

 

/
