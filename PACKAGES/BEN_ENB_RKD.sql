--------------------------------------------------------
--  DDL for Package BEN_ENB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENB_RKD" AUTHID CURRENT_USER as
/* $Header: beenbrhi.pkh 120.0 2005/05/28 02:27:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
   p_enrt_bnft_id                   in number
  ,p_dflt_flag_o                    in  varchar2
  ,p_val_has_bn_prortd_flag_o       in  varchar2
  ,p_bndry_perd_cd_o                in  varchar2
  ,p_val_o                          in  number
  ,p_nnmntry_uom_o                  in  varchar2
  ,p_bnft_typ_cd_o                  in  varchar2
  ,p_entr_val_at_enrt_flag_o        in  varchar2
  ,p_mn_val_o                       in  number
  ,p_mx_val_o                       in  number
  ,p_incrmt_val_o                   in  number
  ,p_dflt_val_o                     in  number
  ,p_rt_typ_cd_o                    in  varchar2
  ,p_cvg_mlt_cd_o                   in  varchar2
  ,p_ctfn_rqd_flag_o                in  varchar2
  ,p_ordr_num_o                     in  number
  ,p_crntly_enrld_flag_o            in  varchar2
  ,p_elig_per_elctbl_chc_id_o       in  number
  ,p_prtt_enrt_rslt_id_o            in  number
  ,p_comp_lvl_fctr_id_o             in  number
  ,p_business_group_id_o            in  number
  ,p_enb_attribute_category_o       in  varchar2
  ,p_enb_attribute1_o               in  varchar2
  ,p_enb_attribute2_o               in  varchar2
  ,p_enb_attribute3_o               in  varchar2
  ,p_enb_attribute4_o               in  varchar2
  ,p_enb_attribute5_o               in  varchar2
  ,p_enb_attribute6_o               in  varchar2
  ,p_enb_attribute7_o               in  varchar2
  ,p_enb_attribute8_o               in  varchar2
  ,p_enb_attribute9_o               in  varchar2
  ,p_enb_attribute10_o              in  varchar2
  ,p_enb_attribute11_o              in  varchar2
  ,p_enb_attribute12_o              in  varchar2
  ,p_enb_attribute13_o              in  varchar2
  ,p_enb_attribute14_o              in  varchar2
  ,p_enb_attribute15_o              in  varchar2
  ,p_enb_attribute16_o              in  varchar2
  ,p_enb_attribute17_o              in  varchar2
  ,p_enb_attribute18_o              in  varchar2
  ,p_enb_attribute19_o              in  varchar2
  ,p_enb_attribute20_o              in  varchar2
  ,p_enb_attribute21_o              in  varchar2
  ,p_enb_attribute22_o              in  varchar2
  ,p_enb_attribute23_o              in  varchar2
  ,p_enb_attribute24_o              in  varchar2
  ,p_enb_attribute25_o              in  varchar2
  ,p_enb_attribute26_o              in  varchar2
  ,p_enb_attribute27_o              in  varchar2
  ,p_enb_attribute28_o              in  varchar2
  ,p_enb_attribute29_o              in  varchar2
  ,p_enb_attribute30_o              in  varchar2
  ,p_request_id_o                   in  number
  ,p_program_application_id_o       in  number
  ,p_program_id_o                   in  number
  ,p_mx_wout_ctfn_val_o             in  number
  ,p_mx_wo_ctfn_flag_o              in  varchar2
  ,p_program_update_date_o          in  date
  ,p_object_version_number_o        in  number
  );
--
end ben_enb_rkd;

 

/
